import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skynova_frontend1/core/routes/app_routes.dart';
import 'package:skynova_frontend1/core/theme/app_theme.dart';
import '../../models/search_model.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../searches/search_details_page.dart';
import '../searches/search_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null || token.isEmpty) return;

    await Future.wait([
      context.read<SearchProvider>().fetchSearches(token),
      context.read<AlertProvider>().fetchAlerts(token),
      authProvider.loadUserProfile(),
    ]);

    if (mounted) {
      setState(() {
        _hasLoaded = true;
      });
    }
  }

  void _openCreateSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchFormPage()),
    );
  }

  void _openAlerts() {
    Navigator.pushNamed(context, AppRoutes.alerts);
  }

  void _openSearches() {
    Navigator.pushNamed(context, AppRoutes.searches);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();
    final alertProvider = context.watch<AlertProvider>();
    final authProvider = context.watch<AuthProvider>();

    final searches = searchProvider.searches;
    final alerts = alertProvider.alerts;
    final user = authProvider.user;
    final displayName =
        user?['name']?.toString() ??
        user?['full_name']?.toString() ??
        'Traveler';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      name: displayName,
                      alertCount: alerts.length,
                      onAlertsTap: _openAlerts,
                    ),
                    const SizedBox(height: 18),
                    _HeroSection(
                      searchCount: searches.length,
                      alertCount: alerts.length,
                      onCreateTap: _openCreateSearch,
                      onAlertTap: _openAlerts,
                    ),
                    const SizedBox(height: 16),
                    _SearchEntryCard(onTap: _openCreateSearch),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.saved_search_rounded,
                            label: 'Saved searches',
                            value: '${searches.length}',
                            sublabel: searches.isEmpty
                                ? 'Create your first route'
                                : 'Ready to track',
                            onTap: _openSearches,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.notifications_active_outlined,
                            label: 'Deal alerts',
                            value: '${alerts.length}',
                            sublabel: alerts.isEmpty
                                ? 'No triggers yet'
                                : 'Monitoring fares',
                            onTap: _openAlerts,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _sectionHeader(
                      theme,
                      'Saved routes',
                      action: 'View all',
                      onAction: _openSearches,
                    ),
                    const SizedBox(height: 12),
                    if (!_hasLoaded &&
                        searchProvider.isLoading &&
                        searches.isEmpty)
                      const _SectionLoader()
                    else if (searches.isEmpty)
                      const _EmptyStateCard(
                        title: 'No searches yet',
                        subtitle:
                            'Save a route to start seeing fare updates, price history, and alert suggestions.',
                        icon: Icons.flight_takeoff,
                      )
                    else
                      ...searches
                          .take(3)
                          .map(
                            (search) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SavedRoutePreview(search: search),
                            ),
                          ),
                    const SizedBox(height: 22),
                    _sectionHeader(theme, 'Travel insights'),
                    const SizedBox(height: 12),
                    _InsightPanel(
                      alertProvider: alertProvider,
                      searches: searches,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    ThemeData theme,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final String name;
  final int alertCount;
  final VoidCallback onAlertsTap;

  const _TopBar({
    required this.name,
    required this.alertCount,
    required this.onAlertsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final secondaryText =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.72) ??
        AppTheme.textMuted;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skynova',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.trustBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back, $name',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track fare drops and saved travel deals in one clean dashboard.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onAlertsTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: onSurface,
                  ),
                ),
                if (alertCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$alertCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final int searchCount;
  final int alertCount;
  final VoidCallback onCreateTap;
  final VoidCallback onAlertTap;

  const _HeroSection({
    required this.searchCount,
    required this.alertCount,
    required this.onCreateTap,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayAlertCount = alertCount > 0 ? alertCount : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF003580), Color(0xFF0A4DA3)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _heroPill(
                icon: Icons.local_offer_outlined,
                label: '$searchCount saved searches',
              ),
              const SizedBox(width: 8),
              _heroPill(
                icon: Icons.notifications_active_outlined,
                label: '$displayAlertCount live alerts',
                onTap: onAlertTap,
                isClickable: true,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Catch the right fare before it’s gone.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitor routes, review price history, and get notified when your travel budget finally lines up.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create a search'),
          ),
        ],
      ),
    );
  }

  Widget _heroPill({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isClickable = false,
  }) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    if (!isClickable) return pill;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: pill,
      ),
    );
  }
}

class _SearchEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final muted =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.70) ??
        AppTheme.textMuted;
    final softSurface = theme.brightness == Brightness.dark
        ? const Color(0xFF162033)
        : const Color(0xFFF8FAFC);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search your next route',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Search destinations, save trips, and track fare changes.',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder),
                  color: softSurface,
                ),
                child: Column(
                  children: [
                    _inputRow(
                      context,
                      Icons.flight_takeoff_rounded,
                      'Origin',
                      'Kingston',
                    ),
                    const Divider(height: 20),
                    _inputRow(
                      context,
                      Icons.flight_land_rounded,
                      'Destination',
                      'New York',
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _smallField(context, 'Depart', 'Jun 18'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _smallField(context, 'Return', 'Jun 27'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Open search'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted =
        theme.textTheme.bodySmall?.color?.withOpacity(0.70) ??
        AppTheme.textMuted;

    return Row(
      children: [
        Icon(icon, color: AppTheme.trustBlue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: muted)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted =
        theme.textTheme.bodySmall?.color?.withOpacity(0.70) ??
        AppTheme.textMuted;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: onSurface),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sublabel;
  final VoidCallback onTap;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.70) ??
        AppTheme.textMuted;
    final chipBg = theme.brightness == Brightness.dark
        ? const Color(0xFF162033)
        : const Color(0xFFEAF2FF);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.trustBlue),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w700, color: onSurface),
              ),
              const SizedBox(height: 4),
              Text(sublabel, style: TextStyle(color: muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedRoutePreview extends StatelessWidget {
  final SearchModel search;

  const _SavedRoutePreview({required this.search});

  String _date(String? value) {
    if (value == null || value.isEmpty) return 'Flexible dates';
    try {
      final parsed = DateTime.parse(value);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.70) ??
        AppTheme.textMuted;
    final chipBg = theme.brightness == Brightness.dark
        ? const Color(0xFF162033)
        : const Color(0xFFEAF2FF);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SearchDetailPage(search: search)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.flight_rounded,
                      color: AppTheme.trustBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${search.origin} → ${search.destination}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _date(search.departDate),
                          style: TextStyle(color: muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: onSurface),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _miniChip(context, 'Tracked'),
                  _miniChip(
                    context,
                    search.returnDate?.isNotEmpty == true
                        ? 'Round trip'
                        : 'One way',
                  ),
                  _miniChip(
                    context,
                    search.maxPrice == null
                        ? 'Any budget'
                        : '${search.currency} ${search.maxPrice!.toStringAsFixed(0)} max',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final chipBg = theme.brightness == Brightness.dark
        ? const Color(0xFF162033)
        : const Color(0xFFF2F4F7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  final AlertProvider alertProvider;
  final List<SearchModel> searches;

  const _InsightPanel({required this.alertProvider, required this.searches});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.70) ??
        AppTheme.textMuted;

    final latest = alertProvider.latestPrice();
    final previous = alertProvider.previousPrice();
    final dropped = latest != null && previous != null && latest < previous;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dropped
                        ? const Color(0xFFEAFBF4)
                        : const Color(0xFFFFF4CC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    dropped
                        ? Icons.trending_down_rounded
                        : Icons.insights_outlined,
                    color: dropped
                        ? AppTheme.successGreen
                        : const Color(0xFF8A5B00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fare movement summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dropped
                  ? 'A tracked fare just dropped from ${previous!.toStringAsFixed(0)} to ${latest!.toStringAsFixed(0)}. This is the right time to surface a deal alert.'
                  : searches.isEmpty
                  ? 'Once you add routes, Skynova will summarize price movement and deal opportunities here.'
                  : 'Your saved routes are being monitored. Price history and alerts will update as new fare snapshots arrive.',
              style: TextStyle(color: muted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.70) ??
        AppTheme.textMuted;
    final iconBg = theme.brightness == Brightness.dark
        ? const Color(0xFF162033)
        : const Color(0xFFEAF2FF);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 36, color: AppTheme.trustBlue),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLoader extends StatelessWidget {
  const _SectionLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
