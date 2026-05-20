import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/models/parsed_financial_entry.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/smart_import_draft_store.dart';
import 'package:imrpo/core/services/shared_text_import_store.dart';
import 'package:imrpo/core/services/transaction_text_parser.dart';
import 'package:imrpo/core/services/sms_bulk_import_service.dart';
import 'package:imrpo/core/services/sms_import_service.dart';
import 'package:imrpo/core/services/sms_imported_registry.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/tab_refresh_overlay.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/expenses_tab/presentation/widgets/add_expense_sheet.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/features/incomes_tab/presentation/widgets/add_income_sheet.dart';
import 'package:imrpo/features/smart_import/presentation/widgets/smart_import_bulk_category_sheet.dart';
import 'package:imrpo/features/smart_import/presentation/widgets/smart_import_quick_add_tab.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
class SmartImportScreen extends StatefulWidget {
  const SmartImportScreen({super.key});

  @override
  State<SmartImportScreen> createState() => _SmartImportScreenState();
}

class _SmartImportScreenState extends State<SmartImportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _pasteController = TextEditingController();
  final _smsService = getIt<SmsImportService>();
  final _bulkImportService = getIt<SmsBulkImportService>();

  bool _pasteParsing = false;
  bool _pasteBulkImporting = false;
  List<ParsedFinancialEntry> _pasteResults = [];
  final Set<int> _pasteSelectedIndices = {};
  bool _quickAddSaving = false;
  int _quickAddVersion = 0;

  bool _smsLoading = false;
  bool _smsLoadingMore = false;
  bool _smsHasMore = false;
  int _smsRawCursor = 0;
  bool _bulkImporting = false;
  List<SmsMessageItem> _smsMessages = [];
  String? _smsError;

  late final SharedTextImportStore _sharedTextStore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _sharedTextStore = getIt<SharedTextImportStore>();
    _sharedTextStore.smartImportScreenOpen = true;
    _sharedTextStore.addListener(_onSharedTextPending);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applySharedTextIfAny());
  }

  @override
  void dispose() {
    _sharedTextStore.removeListener(_onSharedTextPending);
    _sharedTextStore.smartImportScreenOpen = false;
    _tabController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  void _onSharedTextPending() => _applySharedTextIfAny();

  void _applySharedTextIfAny() {
    if (!mounted) return;
    final text = _sharedTextStore.consumePending();
    if (text == null || text.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _tabController.index = 0;
      _pasteController.text = text;
      _pasteResults = [];
      _pasteSelectedIndices.clear();
    });
    _parsePastedText();
    _showSnack(l10n.smartImportSharedTextReady);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SmartImportHeader(
              title: l10n.smartImportTitle,
              tabController: _tabController,
              pasteLabel: l10n.smartImportPasteTab,
              quickLabel: l10n.smartImportQuickTab,
              smsLabel: l10n.smartImportSmsTab,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PasteParseTab(
                    controller: _pasteController,
                    parsing: _pasteParsing,
                    bulkImporting: _pasteBulkImporting,
                    results: _pasteResults,
                    selectedIndices: _pasteSelectedIndices,
                    onPasteFromClipboard: _pasteFromClipboard,
                    onParse: _parsePastedText,
                    onClear: _clearPasteForm,
                    onAddEntry: _addFromPaste,
                    onSwapType: _swapPasteResultType,
                    onToggleSelect: _togglePasteSelection,
                    onSelectAll: _selectAllPasteResults,
                    onClearSelection: _clearPasteSelection,
                    onAddSelected: () => _bulkAddFromPaste(_selectedPasteResults),
                    onAddAllExpenses: () => _bulkAddFromPaste(_pasteExpenseResults),
                    onAddAllIncomes: () => _bulkAddFromPaste(_pasteIncomeResults),
                    onTextChanged: _onPasteTextChanged,
                  ),
                  SmartImportQuickAddTab(
                    key: ValueKey(_quickAddVersion),
                    saving: _quickAddSaving,
                    onAddNow: _quickAddNow,
                    onOpenFullForm: _quickAddOpenForm,
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
          ],
        ),
      ),
    );
  }

  List<ParsedFinancialEntry> get _selectedPasteResults => [
        for (var i = 0; i < _pasteResults.length; i++)
          if (_pasteSelectedIndices.contains(i)) _pasteResults[i],
      ];

  List<ParsedFinancialEntry> get _pasteExpenseResults => _pasteResults
      .where((e) => e.type == FinancialEntryType.expense)
      .toList();

  List<ParsedFinancialEntry> get _pasteIncomeResults =>
      _pasteResults.where((e) => e.type == FinancialEntryType.income).toList();

  void _onPasteTextChanged() {
    setState(() {
      _pasteResults = [];
      _pasteSelectedIndices.clear();
    });
  }

  void _clearPasteForm() {
    setState(() {
      _pasteController.clear();
      _pasteResults = [];
      _pasteSelectedIndices.clear();
    });
  }

  void _togglePasteSelection(int index) {
    setState(() {
      if (_pasteSelectedIndices.contains(index)) {
        _pasteSelectedIndices.remove(index);
      } else {
        _pasteSelectedIndices.add(index);
      }
    });
  }

  void _selectAllPasteResults() {
    setState(() {
      _pasteSelectedIndices
        ..clear()
        ..addAll(List.generate(_pasteResults.length, (i) => i));
    });
  }

  void _clearPasteSelection() => setState(_pasteSelectedIndices.clear);

  Future<void> _pasteFromClipboard() async {
    final l10n = AppLocalizations.of(context)!;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      _showSnack(l10n.smartImportPasteClipboardEmpty, isError: true);
      return;
    }
    setState(() {
      _pasteController.text = text;
      _pasteResults = [];
      _pasteSelectedIndices.clear();
    });
    _parsePastedText();
  }

  void _swapPasteResultType(int index) {
    if (index < 0 || index >= _pasteResults.length) return;
    final current = _pasteResults[index];
    if (!current.hasUsableData) return;
    final swapped = current.copyWith(
      type: current.type == FinancialEntryType.expense
          ? FinancialEntryType.income
          : FinancialEntryType.expense,
    );
    setState(() => _pasteResults[index] = swapped);
    getIt<SmartImportDraftStore>().save(swapped);
  }

  void _reindexPasteSelectionAfterRemove(int removedIndex) {
    final next = <int>{};
    for (final i in _pasteSelectedIndices) {
      if (i == removedIndex) continue;
      next.add(i > removedIndex ? i - 1 : i);
    }
    _pasteSelectedIndices
      ..clear()
      ..addAll(next);
  }

  Future<void> _addFromPaste(ParsedFinancialEntry entry, int index) async {
    final l10n = AppLocalizations.of(context)!;
    final rawTitle = entry.title?.trim();
    final sheetResult = await _showEntrySheet(
      type: entry.type,
      title: (rawTitle != null && rawTitle.isNotEmpty)
          ? rawTitle
          : l10n.smartImportDefaultBillTitle,
      amountInBase: entry.amountInBase,
      date: entry.date,
    );

    if (!mounted) return;
    if (sheetResult == 'added' || sheetResult == 'updated') {
      setState(() {
        if (index >= 0 && index < _pasteResults.length) {
          _pasteResults.removeAt(index);
          _reindexPasteSelectionAfterRemove(index);
        }
        if (_pasteResults.isEmpty) {
          _pasteController.clear();
          _pasteSelectedIndices.clear();
        }
      });
      _showSnack(
        _pasteResults.isEmpty
            ? l10n.smartImportPasteAddedSuccess
            : l10n.smartImportPasteAddedOneRemaining(_pasteResults.length),
      );
    }
  }

  Future<void> _bulkAddFromPaste(List<ParsedFinancialEntry> entries) async {
    final l10n = AppLocalizations.of(context)!;
    final importable =
        entries.where((e) => (e.amountInBase ?? 0) > 0).toList();
    if (importable.isEmpty) {
      _showSnack(l10n.smartImportBulkNothingToAdd, isError: true);
      return;
    }

    final hasExpense = importable.any(
      (e) => e.type == FinancialEntryType.expense,
    );
    final hasIncome = importable.any(
      (e) => e.type == FinancialEntryType.income,
    );

    final categories = await showSmartImportBulkCategorySheet(
      context,
      needsExpenseCategory: hasExpense,
      needsIncomeSource: hasIncome,
    );
    if (categories == null || !mounted) return;

    setState(() => _pasteBulkImporting = true);

    try {
      final result = await _bulkImportService.importParsedEntries(
        importable,
        expenseCategory: categories.expenseCategory,
        incomeSource: categories.incomeSource,
        expensePaidFrom: categories.expensePaidFrom,
      );
      if (!mounted) return;

      context.read<ExpensesTabBloc>().add(const LoadExpensesEvent(force: true));
      context.read<IncomesTabBloc>().add(const LoadIncomesEvent(force: true));

      if (result.hasAny) {
        _clearPasteForm();
        _showSnack(
          l10n.smartImportBulkResult(
            result.incomeCount,
            result.expenseCount,
          ),
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
    } catch (_) {
      if (mounted) {
        _showSnack(l10n.smartImportSmsFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _pasteBulkImporting = false);
    }
  }

  ParsedFinancialEntry _entryFromQuickAdd(QuickAddPayload payload) {
    final displayCode = getIt<CurrencyPreferences>().displayCode;
    final displayAmount =
        getIt<CurrencyPreferences>().displayAmount(payload.amountInBase);
    return ParsedFinancialEntry(
      title: payload.title,
      amount: displayAmount,
      currencyCode: displayCode,
      date: payload.date,
      type: payload.type,
      rawText: 'quick-add',
    );
  }

  Future<void> _quickAddNow(QuickAddPayload payload) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _quickAddSaving = true);
    try {
      final result = await _bulkImportService.importParsedEntries(
        [_entryFromQuickAdd(payload)],
        expenseCategory: payload.expenseCategory,
        incomeSource: payload.incomeSource,
        expensePaidFrom: payload.expensePaidFrom,
      );
      if (!mounted) return;

      context.read<ExpensesTabBloc>().add(const LoadExpensesEvent(force: true));
      context.read<IncomesTabBloc>().add(const LoadIncomesEvent(force: true));

      if (result.hasAny) {
        setState(() => _quickAddVersion++);
        _showSnack(l10n.smartImportQuickAdded);
      } else {
        _showSnack(l10n.smartImportBulkNothingToAdd, isError: true);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(l10n.smartImportSmsFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _quickAddSaving = false);
    }
  }

  Future<void> _quickAddOpenForm(QuickAddPayload payload) async {
    final l10n = AppLocalizations.of(context)!;
    final rawTitle = payload.title?.trim();
    final sheetResult = await _showEntrySheet(
      type: payload.type,
      title: (rawTitle != null && rawTitle.isNotEmpty)
          ? rawTitle
          : l10n.smartImportDefaultBillTitle,
      amountInBase: payload.amountInBase,
      date: payload.date,
    );

    if (!mounted) return;
    if (sheetResult == 'added' || sheetResult == 'updated') {
      setState(() => _quickAddVersion++);
      _showSnack(l10n.smartImportQuickAdded);
    }
  }

  void _parsePastedText() {
    final l10n = AppLocalizations.of(context)!;
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      _showSnack(l10n.smartImportPasteEmpty, isError: true);
      return;
    }

    setState(() => _pasteParsing = true);

    final displayCode = getIt<CurrencyPreferences>().displayCode;
    final parsed = TransactionTextParser.parseMultiplePasted(
      text,
      defaultCurrencyCode: displayCode,
    );

    if (!mounted) return;
    setState(() {
      _pasteParsing = false;
      _pasteResults = parsed;
      _pasteSelectedIndices
        ..clear()
        ..addAll(List.generate(parsed.length, (i) => i));
    });

    if (parsed.isNotEmpty) {
      getIt<SmartImportDraftStore>().save(parsed.first);
    } else {
      _showSnack(l10n.smartImportPasteNoData, isError: true);
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
        _showSnack(
          AppLocalizations.of(context)!.smartImportSmsFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _smsLoadingMore = false);
    }
  }


  Future<void> _bulkImport(
    List<SmsMessageItem> items, {
    String? expenseCategory,
    String? incomeSource,
    String? expensePaidFrom,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final importable = items.where(_bulkImportService.canImport).toList();

    if (importable.isEmpty) {
      _showSnack(l10n.smartImportBulkNothingToAdd, isError: true);
      return;
    }

    setState(() => _bulkImporting = true);

    try {
      final result = await _bulkImportService.importAll(
        importable,
        expenseCategory: expenseCategory,
        incomeSource: incomeSource,
        expensePaidFrom: expensePaidFrom,
      );
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

class _SmartImportHeader extends StatelessWidget {
  final String title;
  final TabController tabController;
  final String pasteLabel;
  final String quickLabel;
  final String smsLabel;

  const _SmartImportHeader({
    required this.title,
    required this.tabController,
    required this.pasteLabel,
    required this.quickLabel,
    required this.smsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textColor,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: tabController,
                tabAlignment: TabAlignment.fill,
                indicator: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: AppDecorations.flatShadow(
                    color: AppColors.stroke,
                    offset: const Offset(0, 2),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.textColor,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                tabs: [
                  Tab(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.content_paste_go_rounded, size: 17),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            pasteLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 17),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            quickLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sms_outlined, size: 17),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            smsLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasteParseTab extends StatelessWidget {
  final TextEditingController controller;
  final bool parsing;
  final bool bulkImporting;
  final List<ParsedFinancialEntry> results;
  final Set<int> selectedIndices;
  final VoidCallback onPasteFromClipboard;
  final VoidCallback onParse;
  final VoidCallback onClear;
  final void Function(ParsedFinancialEntry entry, int index) onAddEntry;
  final ValueChanged<int> onSwapType;
  final ValueChanged<int> onToggleSelect;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onAddSelected;
  final VoidCallback onAddAllExpenses;
  final VoidCallback onAddAllIncomes;
  final VoidCallback onTextChanged;

  const _PasteParseTab({
    required this.controller,
    required this.parsing,
    required this.bulkImporting,
    required this.results,
    required this.selectedIndices,
    required this.onPasteFromClipboard,
    required this.onParse,
    required this.onClear,
    required this.onAddEntry,
    required this.onSwapType,
    required this.onToggleSelect,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onAddSelected,
    required this.onAddAllExpenses,
    required this.onAddAllIncomes,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final disabled = parsing || bulkImporting;
    final expenseCount =
        results.where((e) => e.type == FinancialEntryType.expense).length;
    final incomeCount =
        results.where((e) => e.type == FinancialEntryType.income).length;
    final selectedCount = selectedIndices.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.card(
            borderColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.content_paste_search_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.smartImportPasteHint,
                  style: TextStyle(
                    color: AppColors.textColor.withValues(alpha: 0.72),
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.ios_share_rounded,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.smartImportPasteShareTip,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textColor.withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.smartImportPasteFieldLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final hasText = controller.text.trim().isNotEmpty;
            return TextField(
              controller: controller,
              onChanged: (_) => onTextChanged(),
              maxLines: 12,
              minLines: 5,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 15,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: l10n.smartImportPasteFieldHint,
                hintStyle: TextStyle(
                  color: AppColors.textColor.withValues(alpha: 0.45),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: hasText
                    ? IconButton(
                        onPressed: disabled ? null : onClear,
                        tooltip: l10n.smartImportPasteClear,
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textColor.withValues(alpha: 0.4),
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: disabled ? null : onPasteFromClipboard,
                icon: const Icon(Icons.content_paste_rounded, size: 18),
                label: Text(
                  l10n.smartImportPasteFromClipboard,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: disabled ? null : onParse,
                icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                label: Text(
                  l10n.smartImportParseMessages,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: disabled ? null : onClear,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(l10n.smartImportPasteClear),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textColor.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (parsing) ...[
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: AppDecorations.card(),
            child: Column(
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 14),
                Text(
                  l10n.smartImportPasteProcessing,
                  style: TextStyle(
                    color: AppColors.textColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (results.isNotEmpty && !parsing) ...[
          const SizedBox(height: 20),
          Text(
            l10n.smartImportPasteFoundCount(results.length),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 10),
          if (results.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppDecorations.card(borderColor: AppColors.border),
              child: _SmsBulkActionsBar(
                disabled: disabled,
                importedCount: 0,
                expenseCount: expenseCount,
                incomeCount: incomeCount,
                selectedCount: selectedCount,
                hasSelection: selectedIndices.isNotEmpty,
                onAddAllExpenses: onAddAllExpenses,
                onAddAllIncomes: onAddAllIncomes,
                onAddSelected: onAddSelected,
                onSelectAll: onSelectAll,
                onClearSelection: onClearSelection,
                onClearAllAdded: () {},
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...List.generate(results.length, (index) {
            final entry = results[index];
            final compact = results.length > 1;
            if (compact) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < results.length - 1 ? 10 : 0,
                ),
                child: _PasteResultListTile(
                  entry: entry,
                  index: index,
                  selected: selectedIndices.contains(index),
                  disabled: disabled,
                  onToggleSelect: () => onToggleSelect(index),
                  onAdd: () => onAddEntry(entry, index),
                  onSwapType: () => onSwapType(index),
                ),
              );
            }
            return _ParsedEntryCard(
              entry: entry,
              onAdd: () => onAddEntry(entry, index),
              onClear: onClear,
              onSwapType: () => onSwapType(index),
            );
          }),
        ],
        if (bulkImporting) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.smartImportBulkImporting,
              style: TextStyle(
                color: AppColors.textColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PasteResultListTile extends StatelessWidget {
  final ParsedFinancialEntry entry;
  final int index;
  final bool selected;
  final bool disabled;
  final VoidCallback onToggleSelect;
  final VoidCallback onAdd;
  final VoidCallback onSwapType;

  const _PasteResultListTile({
    required this.entry,
    required this.index,
    required this.selected,
    required this.disabled,
    required this.onToggleSelect,
    required this.onAdd,
    required this.onSwapType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isExpense = entry.type == FinancialEntryType.expense;
    final accent = isExpense ? AppColors.expense : AppColors.income;
    final rawTitle = entry.title?.trim();
    final title = (rawTitle != null && rawTitle.isNotEmpty)
        ? rawTitle
        : l10n.smartImportDefaultBillTitle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onToggleSelect,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppDecorations.card(
            borderColor: selected
                ? AppColors.primary.withValues(alpha: 0.45)
                : accent.withValues(alpha: 0.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: disabled ? null : (_) => onToggleSelect(),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (entry.amountInBase != null)
                          ListenableBuilder(
                            listenable: getIt<CurrencyPreferences>(),
                            builder: (context, _) => Text(
                              Money.format(entry.amountInBase!),
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          isExpense ? l10n.tabExpenses : l10n.tabIncomes,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textColor.withValues(alpha: 0.55),
                          ),
                        ),
                        if (entry.date != null)
                          Text(
                            DateFormat.yMMMd(locale).format(entry.date!),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textColor.withValues(alpha: 0.45),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: disabled ? null : onSwapType,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: Text(
                        isExpense
                            ? l10n.smartImportPasteMarkIncome
                            : l10n.smartImportPasteMarkExpense,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isExpense ? AppColors.income : AppColors.expense,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: disabled ? null : onAdd,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.smartImportAddToApp),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
  final Future<void> Function(
    List<SmsMessageItem> items, {
    String? expenseCategory,
    String? incomeSource,
    String? expensePaidFrom,
  })
  onBulkImport;
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
    if (widget.bulkImporting || items.isEmpty) return;

    final hasExpense = items.any(
      (m) => m.parsed.type == FinancialEntryType.expense,
    );
    final hasIncome = items.any(
      (m) => m.parsed.type == FinancialEntryType.income,
    );
    if (!hasExpense && !hasIncome) return;

    final categories = await showSmartImportBulkCategorySheet(
      context,
      needsExpenseCategory: hasExpense,
      needsIncomeSource: hasIncome,
    );
    if (categories == null || !mounted) return;

    await widget.onBulkImport(
      items,
      expenseCategory: categories.expenseCategory,
      incomeSource: categories.incomeSource,
      expensePaidFrom: categories.expensePaidFrom,
    );
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

    final isInitialLoading = widget.loading && widget.messages.isEmpty;
    final isRefreshing = widget.loading && widget.messages.isNotEmpty;

    Widget body;
    if (isInitialLoading) {
      body = _SmsLoadingList(message: l10n.smartImportSmsLoading);
    } else if (widget.messages.isEmpty) {
      body = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _CenterMessage(
            icon: Icons.sms_failed_outlined,
            message: widget.error ?? l10n.smartImportSmsEmpty,
            actionLabel: l10n.smartImportReloadSms,
            onAction: widget.onRefresh,
          ),
        ],
      );
    } else {
      body = ListenableBuilder(
        listenable: _importedRegistry,
        builder: (context, _) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppDecorations.card(
                      borderColor: AppColors.border,
                    ),
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
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: widget.messages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = widget.messages[index];
                    final isImported = _importedRegistry.isImported(item.id);
                    final canImport = _bulkImportService.canImport(item);
                    final canReimport =
                        isImported && _bulkImportService.canReimport(item);
                    return _SmsListTile(
                      item: item,
                      isImported: isImported,
                      canImport: canImport,
                      canReimport: canReimport,
                      selected: _selectedIds.contains(item.id),
                      disabled: disabled,
                      onToggleSelect:
                          canImport ? () => _toggleSelection(item) : null,
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
      );
    }

    return Stack(
      children: [
        TabRefreshOverlay(
          isRefreshing: isRefreshing,
          indicatorColor: AppColors.primary,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: disabled
                ? () async {}
                : () async {
                    widget.onRefresh();
                  },
            child: body,
          ),
        ),
        if (widget.bulkImporting)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.scaffold.withValues(alpha: 0.85),
              child: Center(
                child: _BulkImportProgressCard(
                  message: l10n.smartImportBulkImporting,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BulkImportProgressCard extends StatelessWidget {
  final String message;

  const _BulkImportProgressCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      decoration: AppDecorations.card(borderColor: AppColors.primary),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmsLoadingList extends StatelessWidget {
  final String message;

  const _SmsLoadingList({required this.message});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.card(
                borderColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor.withValues(alpha: 0.75),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) => const _SmsSkeletonTile(),
          ),
        ),
      ],
    );
  }
}

class _SmsSkeletonTile extends StatelessWidget {
  const _SmsSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(borderColor: AppColors.border),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmsPaginationFooter extends StatelessWidget {
  final bool loading;
  final VoidCallback onLoadMore;

  const _SmsPaginationFooter({required this.loading, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.smartImportSmsLoadingMore,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
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
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
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

    final accent = isExpense ? AppColors.expense : AppColors.income;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled || isImported ? null : (onToggleSelect ?? onAdd),
        onLongPress: disabled || !canImport || isImported ? null : onAdd,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppDecorations.card(
            borderColor: isImported
                ? AppColors.border
                : selected
                    ? AppColors.primary
                    : accent.withValues(alpha: 0.18),
          ).copyWith(
            color: isImported
                ? AppColors.surface
                : selected
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.card,
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
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sms_outlined,
                      size: 20,
                      color: accent,
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
                              color: AppColors.textColor.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMMMd(
                            locale,
                          ).add_jm().format(parsed.date ?? item.date),
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
                          color: accent,
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
                      color: accent,
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
  final VoidCallback? onClear;
  final VoidCallback? onSwapType;

  const _ParsedEntryCard({
    required this.entry,
    required this.onAdd,
    this.onClear,
    this.onSwapType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isExpense = entry.type == FinancialEntryType.expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(
        borderColor: (isExpense ? AppColors.expense : AppColors.income)
            .withValues(alpha: 0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isExpense ? AppColors.expense : AppColors.income)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isExpense
                      ? Icons.north_east_rounded
                      : Icons.south_west_rounded,
                  size: 18,
                  color: isExpense ? AppColors.expense : AppColors.income,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.smartImportExtractedData,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n.titleField,
            value: () {
              final t = entry.title?.trim();
              if (t != null && t.isNotEmpty) return t;
              return l10n.smartImportDefaultBillTitle;
            }(),
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
                backgroundColor:
                    isExpense ? AppColors.expense : AppColors.income,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (onSwapType != null || onClear != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onSwapType != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSwapType,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: Text(
                        isExpense
                            ? l10n.smartImportPasteMarkIncome
                            : l10n.smartImportPasteMarkExpense,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isExpense ? AppColors.income : AppColors.expense,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (onSwapType != null && onClear != null)
                  const SizedBox(width: 8),
                if (onClear != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(l10n.smartImportPasteParseAnother),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
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

// ignore: unused_element
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: AppDecorations.card(
            borderColor: color.withValues(alpha: 0.35),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.7),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: AppDecorations.card(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.textColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor.withValues(alpha: 0.65),
                height: 1.45,
                fontSize: 14,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
