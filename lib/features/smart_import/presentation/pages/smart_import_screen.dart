import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imrpo/core/models/parsed_financial_entry.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/invoice_ocr_service.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/sms_bulk_import_service.dart';
import 'package:imrpo/core/services/sms_import_service.dart';
import 'package:imrpo/core/services/sms_imported_registry.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/expenses_tab/presentation/widgets/add_expense_sheet.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/features/incomes_tab/presentation/widgets/add_income_sheet.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class SmartImportScreen extends StatefulWidget {
  const SmartImportScreen({super.key});

  @override
  State<SmartImportScreen> createState() => _SmartImportScreenState();
}

class _SmartImportScreenState extends State<SmartImportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _ocrService = getIt<InvoiceOcrService>();
  final _smsService = getIt<SmsImportService>();
  final _bulkImportService = getIt<SmsBulkImportService>();
  final _imagePicker = ImagePicker();

  bool _ocrLoading = false;
  ParsedFinancialEntry? _ocrResult;
  String? _ocrPreviewPath;

  bool _smsLoading = false;
  bool _smsLoadingMore = false;
  bool _smsHasMore = false;
  int _smsRawCursor = 0;
  bool _bulkImporting = false;
  List<SmsMessageItem> _smsMessages = [];
  String? _smsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.scaffold,
          appBar: AppBar(
            title: Text(l10n.smartImportTitle),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  text: l10n.smartImportInvoiceTab,
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
                Tab(
                  text: l10n.smartImportSmsTab,
                  icon: const Icon(Icons.sms_outlined),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _InvoiceOcrTab(
                loading: _ocrLoading,
                previewPath: _ocrPreviewPath,
                result: _ocrResult,
                onScanCamera: () => _scanInvoice(ImageSource.camera),
                onScanGallery: () => _scanInvoice(ImageSource.gallery),
                onAddEntry: _openPrefilledSheet,
              ),
              _SmsImportTab(
                loading: _smsLoading,
                loadingMore: _smsLoadingMore,
                hasMore: _smsHasMore,
                bulkImporting: _bulkImporting,
                messages: _smsMessages,
                error: _smsError,
                smsSupported: _smsService.isSupported,
                onRefresh: _loadSms,
                onLoadMore: _loadMoreSms,
                onAddEntry: _openPrefilledSheetFromSms,
                onBulkImport: _bulkImport,
                onClearAllAdded: _confirmClearAllImportedSms,
              ),
            ],
          ),
        ),
        if (_bulkImporting)
          const ModalBarrier(dismissible: false, color: Colors.black26),
        if (_bulkImporting)
          Center(
            child: Card(
              margin: const EdgeInsets.all(32),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      l10n.smartImportBulkImporting,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _scanInvoice(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;

    if (source == ImageSource.camera) {
      final camera = await Permission.camera.request();
      if (!camera.isGranted) {
        _showSnack(l10n.smartImportCameraDenied, isError: true);
        return;
      }
    }

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _ocrLoading = true;
      _ocrPreviewPath = picked.path;
      _ocrResult = null;
    });

    try {
      final parsed = await _ocrService.scanImage(picked.path);
      if (!mounted) return;
      setState(() => _ocrResult = parsed);

      if (!parsed.hasUsableData) {
        _showSnack(l10n.smartImportOcrNoData, isError: true);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack(l10n.smartImportOcrFailed, isError: true);
    } finally {
      if (mounted) setState(() => _ocrLoading = false);
    }
  }

  Future<void> _loadSms() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_smsService.isSupported) {
      setState(() {
        _smsError = l10n.smartImportSmsNotSupported;
        _smsMessages = [];
        _smsHasMore = false;
      });
      return;
    }

    setState(() {
      _smsLoading = true;
      _smsError = null;
      _smsRawCursor = 0;
      _smsHasMore = true;
    });

    try {
      final page = await _smsService.loadInitialFinancialMessages();
      if (!mounted) return;
      setState(() {
        _smsMessages = page.items;
        _smsRawCursor = page.nextRawStart;
        _smsHasMore = page.hasMore;
        if (page.items.isEmpty) {
          _smsError = l10n.smartImportSmsEmpty;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _smsMessages = [];
        _smsHasMore = false;
        _smsError = l10n.smartImportSmsFailed;
      });
    } finally {
      if (mounted) setState(() => _smsLoading = false);
    }
  }

  Future<void> _loadMoreSms() async {
    if (_smsLoading || _smsLoadingMore || !_smsHasMore) return;

    setState(() => _smsLoadingMore = true);

    try {
      final page = await _smsService.loadFinancialMessagesPage(
        rawStart: _smsRawCursor,
        pageSize: 40,
      );
      if (!mounted) return;

      final existingIds = _smsMessages.map((m) => m.id).toSet();
      final novel = page.items.where((m) => !existingIds.contains(m.id));

      setState(() {
        _smsMessages = [..._smsMessages, ...novel];
        _smsRawCursor = page.nextRawStart;
        _smsHasMore = page.hasMore;
      });
    } catch (_) {
      if (mounted) {
        _showSnack(AppLocalizations.of(context)!.smartImportSmsFailed,
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _smsLoadingMore = false);
    }
  }

  Future<void> _openPrefilledSheet(ParsedFinancialEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    await _showEntrySheet(
      type: entry.type,
      title: l10n.smartImportDefaultBillTitle,
      amountInBase: entry.amountInBase,
      date: entry.date,
    );
  }

  Future<void> _bulkImport(List<SmsMessageItem> items) async {
    final l10n = AppLocalizations.of(context)!;
    final importable = items.where(_bulkImportService.canImport).toList();

    if (importable.isEmpty) {
      _showSnack(l10n.smartImportBulkNothingToAdd, isError: true);
      return;
    }

    setState(() => _bulkImporting = true);

    try {
      final result = await _bulkImportService.importAll(importable);
      if (!mounted) return;

      context.read<ExpensesTabBloc>().add(const LoadExpensesEvent(force: true));
      context.read<IncomesTabBloc>().add(const LoadIncomesEvent(force: true));

      if (result.hasAny) {
        _showSnack(
          l10n.smartImportBulkResult(result.incomeCount, result.expenseCount),
        );
      } else {
        _showSnack(l10n.smartImportBulkNothingToAdd, isError: true);
      }

      if (result.failed > 0) {
        _showSnack(
          l10n.smartImportBulkPartialFail(result.failed),
          isError: true,
        );
      }
      if (result.skipped > 0) {
        _showSnack(l10n.smartImportSmsSkippedDuplicate(result.skipped));
      }
    } catch (_) {
      if (mounted) {
        _showSnack(l10n.smartImportSmsFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _bulkImporting = false);
    }
  }

  Future<void> _confirmClearAllImportedSms() async {
    final l10n = AppLocalizations.of(context)!;
    final registry = getIt<SmsImportedRegistry>();
    if (registry.importedCount == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.smartImportSmsClearAllAddedConfirmTitle),
        content: Text(l10n.smartImportSmsClearAllAddedConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.smartImportSmsClearAllAdded),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await registry.clearAll();
    if (!mounted) return;
    _showSnack(l10n.smartImportSmsClearAllAddedDone);
  }

  Future<void> _openPrefilledSheetFromSms(
    SmsMessageItem item, {
    bool reimport = false,
  }) async {
    final registry = getIt<SmsImportedRegistry>();

    if (!reimport && registry.isImported(item.id)) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final fallback = item.parsed.type == FinancialEntryType.expense
        ? l10n.smartImportSmsTitleExpense
        : l10n.smartImportSmsTitleIncome;
    final result = await _showEntrySheet(
      type: item.parsed.type,
      title: item.displayTitle(fallback),
      amountInBase: item.parsed.amountInBase,
      date: item.parsed.date ?? item.date,
    );

    if (result == 'added' || result == 'updated') {
      await registry.markImported(item.id);
    }
  }

  Future<String?> _showEntrySheet({
    required FinancialEntryType type,
    String? title,
    double? amountInBase,
    DateTime? date,
  }) async {
    final displayAmount = amountInBase != null
        ? getIt<CurrencyPreferences>().displayAmount(amountInBase)
        : null;
    final isExpense = type == FinancialEntryType.expense;
    final sheet = isExpense
        ? AddExpenseSheet(
            initialTitle: title,
            initialAmount: displayAmount,
            initialDate: date,
          )
        : AddIncomeSheet(
            initialTitle: title,
            initialAmount: displayAmount,
            initialDate: date,
          );

    if (!mounted) return null;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: isExpense
            ? BlocProvider.value(
                value: context.read<ExpensesTabBloc>(),
                child: sheet,
              )
            : BlocProvider.value(
                value: context.read<IncomesTabBloc>(),
                child: sheet,
              ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorColor : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _InvoiceOcrTab extends StatelessWidget {
  final bool loading;
  final String? previewPath;
  final ParsedFinancialEntry? result;
  final VoidCallback onScanCamera;
  final VoidCallback onScanGallery;
  final ValueChanged<ParsedFinancialEntry> onAddEntry;

  const _InvoiceOcrTab({
    required this.loading,
    required this.previewPath,
    required this.result,
    required this.onScanCamera,
    required this.onScanGallery,
    required this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.smartImportInvoiceHint,
          style: TextStyle(
            color: AppColors.textColor.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_camera_outlined,
                label: l10n.smartImportScanCamera,
                color: AppColors.expense,
                onTap: loading ? null : onScanCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library_outlined,
                label: l10n.smartImportScanGallery,
                color: AppColors.primary,
                onTap: loading ? null : onScanGallery,
              ),
            ),
          ],
        ),
        if (loading) ...[
          const SizedBox(height: 32),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l10n.smartImportOcrProcessing,
              style: TextStyle(
                color: AppColors.textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
        if (previewPath != null && !loading) ...[
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(previewPath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
        if (result != null && result!.hasUsableData && !loading) ...[
          const SizedBox(height: 24),
          _ParsedEntryCard(entry: result!, onAdd: () => onAddEntry(result!)),
        ],
      ],
    );
  }
}

class _SmsImportTab extends StatefulWidget {
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final bool bulkImporting;
  final List<SmsMessageItem> messages;
  final String? error;
  final bool smsSupported;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final Future<void> Function(SmsMessageItem item, {bool reimport}) onAddEntry;
  final Future<void> Function(List<SmsMessageItem> items) onBulkImport;
  final VoidCallback onClearAllAdded;

  const _SmsImportTab({
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.bulkImporting,
    required this.messages,
    required this.error,
    required this.smsSupported,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onAddEntry,
    required this.onBulkImport,
    required this.onClearAllAdded,
  });

  @override
  State<_SmsImportTab> createState() => _SmsImportTabState();
}

class _SmsImportTabState extends State<_SmsImportTab> {
  bool _requested = false;
  final Set<String> _selectedIds = {};
  late final ScrollController _scrollController;
  bool _loadMoreScheduled = false;
  final _bulkImportService = getIt<SmsBulkImportService>();
  final _importedRegistry = getIt<SmsImportedRegistry>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore ||
        widget.loadingMore ||
        widget.loading ||
        widget.bulkImporting) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) return;
    if (_loadMoreScheduled) return;
    _loadMoreScheduled = true;
    widget.onLoadMore();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _loadMoreScheduled = false;
    });
  }

  List<SmsMessageItem> get _importable =>
      widget.messages.where(_bulkImportService.canImport).toList();

  List<SmsMessageItem> get _expenseItems => _importable
      .where((m) => m.parsed.type == FinancialEntryType.expense)
      .toList();

  List<SmsMessageItem> get _incomeItems => _importable
      .where((m) => m.parsed.type == FinancialEntryType.income)
      .toList();

  List<SmsMessageItem> get _selectedItems => widget.messages
      .where((m) => _selectedIds.contains(m.id))
      .where(_bulkImportService.canImport)
      .toList();

  @override
  void didUpdateWidget(covariant _SmsImportTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _selectedIds.removeWhere((id) => !widget.messages.any((m) => m.id == id));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested && widget.smsSupported) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRefresh());
    }
  }

  void _toggleSelection(SmsMessageItem item) {
    if (!_bulkImportService.canImport(item)) return;
    setState(() {
      if (_selectedIds.contains(item.id)) {
        _selectedIds.remove(item.id);
      } else {
        _selectedIds.add(item.id);
      }
    });
  }

  void _selectAllImportable() {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(_importable.map((m) => m.id));
    });
  }

  void _clearSelection() => setState(_selectedIds.clear);

  Future<void> _runBulk(List<SmsMessageItem> items) async {
    if (widget.bulkImporting) return;
    await widget.onBulkImport(items);
    if (mounted) setState(_selectedIds.clear);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final disabled = widget.bulkImporting;

    if (!widget.smsSupported) {
      return _CenterMessage(
        icon: Icons.phone_iphone_outlined,
        message: l10n.smartImportSmsNotSupported,
      );
    }

    if (widget.loading && widget.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: disabled ? () async {} : () async => widget.onRefresh(),
      child: widget.messages.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                _CenterMessage(
                  icon: Icons.sms_failed_outlined,
                  message: widget.error ?? l10n.smartImportSmsEmpty,
                  actionLabel: l10n.smartImportReloadSms,
                  onAction: widget.onRefresh,
                ),
              ],
            )
          : ListenableBuilder(
              listenable: _importedRegistry,
              builder: (context, _) {
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: _SmsBulkActionsBar(
                          disabled: disabled,
                          importedCount: _importedRegistry.importedCount,
                          expenseCount: _expenseItems.length,
                          incomeCount: _incomeItems.length,
                          selectedCount: _selectedItems.length,
                          hasSelection: _selectedIds.isNotEmpty,
                          onAddAllExpenses: () => _runBulk(_expenseItems),
                          onAddAllIncomes: () => _runBulk(_incomeItems),
                          onAddSelected: () => _runBulk(_selectedItems),
                          onSelectAll: _selectAllImportable,
                          onClearSelection: _clearSelection,
                          onClearAllAdded: widget.onClearAllAdded,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: widget.messages.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = widget.messages[index];
                          final isImported =
                              _importedRegistry.isImported(item.id);
                          final canImport =
                              _bulkImportService.canImport(item);
                          final canReimport =
                              isImported && _bulkImportService.canReimport(item);
                          return _SmsListTile(
                            item: item,
                            isImported: isImported,
                            canImport: canImport,
                            canReimport: canReimport,
                            selected: _selectedIds.contains(item.id),
                            disabled: disabled,
                            onToggleSelect: canImport
                                ? () => _toggleSelection(item)
                                : null,
                            onAdd: () => widget.onAddEntry(item),
                            onAddAgain: canReimport
                                ? () => widget.onAddEntry(item, reimport: true)
                                : null,
                          );
                        },
                      ),
                    ),
                    if (widget.hasMore || widget.loadingMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: _SmsPaginationFooter(
                            loading: widget.loadingMore,
                            onLoadMore: widget.onLoadMore,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _SmsPaginationFooter extends StatelessWidget {
  final bool loading;
  final VoidCallback onLoadMore;

  const _SmsPaginationFooter({
    required this.loading,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onLoadMore,
      icon: const Icon(Icons.expand_more_rounded),
      label: Text(l10n.smartImportSmsLoadMore),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _SmsBulkActionsBar extends StatelessWidget {
  final bool disabled;
  final int importedCount;
  final int expenseCount;
  final int incomeCount;
  final int selectedCount;
  final bool hasSelection;
  final VoidCallback onAddAllExpenses;
  final VoidCallback onAddAllIncomes;
  final VoidCallback onAddSelected;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onClearAllAdded;

  const _SmsBulkActionsBar({
    required this.disabled,
    required this.importedCount,
    required this.expenseCount,
    required this.incomeCount,
    required this.selectedCount,
    required this.hasSelection,
    required this.onAddAllExpenses,
    required this.onAddAllIncomes,
    required this.onAddSelected,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onClearAllAdded,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BulkChip(
              label: l10n.smartImportAddAllExpenses(expenseCount),
              icon: Icons.north_east_rounded,
              color: AppColors.expense,
              onTap: disabled || expenseCount == 0 ? null : onAddAllExpenses,
            ),
            _BulkChip(
              label: l10n.smartImportAddAllIncomes(incomeCount),
              icon: Icons.south_west_rounded,
              color: AppColors.income,
              onTap: disabled || incomeCount == 0 ? null : onAddAllIncomes,
            ),
          ],
        ),
        if (importedCount > 0) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: disabled ? null : onClearAllAdded,
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: Text(l10n.smartImportSmsClearAllAdded),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.expense,
              ),
            ),
          ),
        ],
        if (hasSelection) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: disabled || selectedCount == 0
                      ? null
                      : onAddSelected,
                  icon: const Icon(Icons.playlist_add_check_rounded, size: 20),
                  label: Text(l10n.smartImportAddSelected(selectedCount)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: disabled ? null : onClearSelection,
                child: Text(l10n.smartImportClearSelection),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: disabled ? null : onSelectAll,
              icon: const Icon(Icons.select_all_rounded, size: 18),
              label: Text(l10n.smartImportSelectAll),
            ),
          ),
        ],
      ],
    );
  }
}

class _BulkChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _BulkChip({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmsListTile extends StatelessWidget {
  final SmsMessageItem item;
  final bool isImported;
  final bool canImport;
  final bool canReimport;
  final bool selected;
  final bool disabled;
  final VoidCallback? onToggleSelect;
  final VoidCallback onAdd;
  final VoidCallback? onAddAgain;

  const _SmsListTile({
    required this.item,
    required this.isImported,
    required this.canImport,
    required this.canReimport,
    required this.selected,
    required this.disabled,
    required this.onToggleSelect,
    required this.onAdd,
    this.onAddAgain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final parsed = item.parsed;
    final isExpense = parsed.type == FinancialEntryType.expense;

    return Material(
      color: isImported
          ? AppColors.surface
          : selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: disabled || isImported ? null : (onToggleSelect ?? onAdd),
        onLongPress: disabled || !canImport || isImported ? null : onAdd,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isImported
                  ? AppColors.border
                  : selected
                      ? AppColors.primary
                      : AppColors.border,
              width: selected && !isImported ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canImport)
                    Checkbox(
                      value: selected,
                      onChanged: disabled
                          ? null
                          : (_) => onToggleSelect?.call(),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isExpense ? AppColors.expense : AppColors.income)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sms_outlined,
                      size: 20,
                      color: isExpense ? AppColors.expense : AppColors.income,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayTitle(
                            parsed.type == FinancialEntryType.expense
                                ? l10n.smartImportSmsTitleExpense
                                : l10n.smartImportSmsTitleIncome,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.displaySubtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.displaySubtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textColor.withValues(alpha: 0.45),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMMMd(locale)
                              .add_jm()
                              .format(parsed.date ?? item.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (parsed.amountInBase != null)
                    ListenableBuilder(
                      listenable: getIt<CurrencyPreferences>(),
                      builder: (context, _) => Text(
                        Money.format(parsed.amountInBase!),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color:
                              isExpense ? AppColors.expense : AppColors.income,
                        ),
                      ),
                    ),
                  if (!disabled && canImport && !isImported) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(Icons.open_in_new_rounded),
                      color: AppColors.primary,
                      tooltip: l10n.smartImportTapToImport,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: canImport ? 40 : 12),
                child: Row(
                  children: [
                    Icon(
                      isExpense
                          ? Icons.north_east_rounded
                          : Icons.south_west_rounded,
                      size: 14,
                      color: isExpense ? AppColors.expense : AppColors.income,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpense ? l10n.tabExpenses : l10n.tabIncomes,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor.withValues(alpha: 0.55),
                      ),
                    ),
                    if (isImported) ...[
                      const Spacer(),
                      if (canReimport && onAddAgain != null && !disabled)
                        TextButton(
                          onPressed: onAddAgain,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.smartImportSmsAddAgain,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.smartImportSmsAlreadyAdded,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ] else if (!canImport) ...[
                      const Spacer(),
                      Text(
                        '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ] else ...[
                      const Spacer(),
                      Text(
                        l10n.smartImportTapToImport,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textColor.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParsedEntryCard extends StatelessWidget {
  final ParsedFinancialEntry entry;
  final VoidCallback onAdd;

  const _ParsedEntryCard({required this.entry, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isExpense = entry.type == FinancialEntryType.expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.smartImportExtractedData,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n.titleField,
            value: l10n.smartImportDefaultBillTitle,
          ),
          if (entry.amountInBase != null)
            ListenableBuilder(
              listenable: getIt<CurrencyPreferences>(),
              builder: (context, _) => _InfoRow(
                label: l10n.amountField,
                value: Money.format(entry.amountInBase!),
              ),
            ),
          if (entry.date != null)
            _InfoRow(
              label: l10n.smartImportDateField,
              value: DateFormat.yMMMd(locale).format(entry.date!),
            ),
          _InfoRow(
            label: l10n.smartImportTypeField,
            value: isExpense ? l10n.tabExpenses : l10n.tabIncomes,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.smartImportAddToApp),
              style: FilledButton.styleFrom(
                backgroundColor: isExpense
                    ? AppColors.expense
                    : AppColors.income,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textColor.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenterMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textColor.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textColor.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
