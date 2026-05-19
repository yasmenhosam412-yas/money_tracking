import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/features/home/domain/entities/user_profile.dart';
import 'package:imrpo/features/home/presentation/bloc/home_bloc.dart';
import 'package:imrpo/features/home/presentation/widgets/user_settings_sheet.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/home/presentation/widgets/home_date_filter_sheet.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/display_currency_selector.dart';
import 'package:imrpo/features/balance_tab/presentation/pages/balance_tab.dart';
import 'package:imrpo/features/expenses_tab/presentation/pages/expenses_tab.dart';
import 'package:imrpo/features/incomes_tab/presentation/pages/incomes_tab.dart';
import 'package:imrpo/features/plans_tab/presentation/pages/plans_tab.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _HomeTabBody(tabController: _tabController);
  }
}

class _HomeTabBody extends StatefulWidget {
  final TabController tabController;

  const _HomeTabBody({required this.tabController});

  @override
  State<_HomeTabBody> createState() => _HomeTabBodyState();
}

class _HomeTabBodyState extends State<_HomeTabBody> {
  List<_HomeTabItem> _tabs(AppLocalizations l10n) => [
        _HomeTabItem(
          label: l10n.tabIncomes,
          icon: Icons.south_west_rounded,
          color: AppColors.income,
        ),
        _HomeTabItem(
          label: l10n.tabExpenses,
          icon: Icons.north_east_rounded,
          color: AppColors.expense,
        ),
        _HomeTabItem(
          label: l10n.tabBalance,
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.balance,
        ),
        _HomeTabItem(
          label: l10n.tabPlans,
          icon: Icons.flag_outlined,
          color: AppColors.plans,
        ),
      ];

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _tabs(l10n);
    final selected = widget.tabController.index;
    final selectedTab = tabs[selected];

    return ListenableBuilder(
      listenable: getIt<CurrencyPreferences>(),
      builder: (context, _) {
        return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Column(
        children: [
          _HomeHeader(accentColor: selectedTab.color),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isSelected = selected == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == tabs.length - 1 ? 0 : 4,
                    ),
                    child: _TabChip(
                      tab: tab,
                      isSelected: isSelected,
                      onTap: () => widget.tabController.animateTo(index),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: const [
                IncomesTab(),
                ExpensesTab(),
                BalanceTab(),
                PlansTab(),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _HomeTabItem {
  final String label;
  final IconData icon;
  final Color color;

  const _HomeTabItem({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _HomeHeader extends StatelessWidget {
  final Color accentColor;

  const _HomeHeader({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.paddingOf(context).top;
    final dateFilter = getIt<HomeDateFilter>();

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        final profile = homeState.profile;
        final isInitialLoading = homeState.isInitialLoading;
        final isRefreshingProfile = homeState.isRefreshingProfile ||
            homeState.isUpdatingUsername;

        return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            Color.lerp(AppColors.primary, accentColor, 0.4)!,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
        padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
        child: Row(
          children: [
            _UserAvatar(
              profile: profile,
              isInitialLoading: isInitialLoading,
              isRefreshing: isRefreshingProfile,
              onTap: profile != null && !isInitialLoading
                  ? () => showUserSettingsSheet(context, profile)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _welcomeLine(l10n, profile, isInitialLoading),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeFinanceOverview,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (profile != null && profile.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const DisplayCurrencySelector(lightStyle: true),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: dateFilter,
                  builder: (context, _) {
                    return _DateFilterChip(
                      label: dateFilter.headerLabel(context),
                      isDayMode: dateFilter.isDayMode,
                      isActive: dateFilter.isFiltered,
                      onTap: () => showHomeDateFilterSheet(context),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
          if (isRefreshingProfile)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: Colors.white,
                backgroundColor: Colors.white24,
              ),
            ),
        ],
      ),
    );
      },
    );
  }

  String _welcomeLine(
    AppLocalizations l10n,
    UserProfile? profile,
    bool isInitialLoading,
  ) {
    if (isInitialLoading) return l10n.homeWelcomeBack;
    if (profile != null && profile.displayName.isNotEmpty) {
      return l10n.homeWelcomeUser(profile.displayName);
    }
    return l10n.homeWelcomeBack;
  }
}

class _DateFilterChip extends StatelessWidget {
  final String label;
  final bool isDayMode;
  final bool isActive;
  final VoidCallback onTap;

  const _DateFilterChip({
    required this.label,
    required this.isDayMode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? Border.all(color: Colors.white.withValues(alpha: 0.45))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDayMode
                    ? Icons.today_outlined
                    : Icons.calendar_month_outlined,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final UserProfile? profile;
  final bool isInitialLoading;
  final bool isRefreshing;
  final VoidCallback? onTap;

  const _UserAvatar({
    required this.profile,
    required this.isInitialLoading,
    this.isRefreshing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = _initial(profile);

    final avatar = Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: isInitialLoading
          ? Padding(
              padding: const EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: initial != null
                      ? Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(
                          Icons.pie_chart_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
                if (isRefreshing)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
              ],
            ),
    );

    if (onTap == null) return avatar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: avatar,
      ),
    );
  }

  String? _initial(UserProfile? profile) {
    if (profile == null || profile.displayName.isEmpty) return null;
    return profile.displayName[0].toUpperCase();
  }
}

class _TabChip extends StatelessWidget {
  final _HomeTabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? tab.color : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? tab.color : AppColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: tab.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tab.icon,
                size: 20,
                color: isSelected ? Colors.white : tab.color,
              ),
              const SizedBox(height: 6),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
