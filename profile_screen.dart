import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../config/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        surfaceTintColor: Colors.transparent,
        title: Text('Profile',
            style: GoogleFonts.inter(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) return _SignInPrompt();
          return _AuthenticatedBody(auth: auth);
        },
      ),
    );
  }
}

// ─── NOT SIGNED IN ───────────────────────────────────────────
class _SignInPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.elevated,
                  border: Border.all(color: AppColors.border)),
              child: ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                        colors: [AppColors.gold, AppColors.goldBright])
                    .createShader(b),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text('Not Signed In',
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Sign in to access your profile and track your requests.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Text('Sign In',
                    style: GoogleFonts.inter(
                        color: AppColors.obsidian,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Create Account',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AUTHENTICATED BODY ───────────────────────────────────────
class _AuthenticatedBody extends StatelessWidget {
  final AuthProvider auth;
  const _AuthenticatedBody({required this.auth});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ProfileHeader(auth: auth),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _InfoCard(auth: auth),
                const SizedBox(height: 14),
                _QuickLinksCard(),
                const SizedBox(height: 14),
                _InternationalLinksCard(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      auth.logout();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (_) => false);
                    },
                    icon: const Icon(Icons.logout_rounded,
                        size: 18, color: AppColors.error),
                    label: Text('Sign Out',
                        style: GoogleFonts.inter(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PROFILE HEADER ───────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final AuthProvider auth;
  const _ProfileHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: AppColors.charcoal,
          border: Border(bottom: BorderSide(color: AppColors.border))),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                const LinearGradient(colors: [AppColors.goldDim, AppColors.gold]),
            boxShadow: [
              BoxShadow(
                  color: AppColors.gold.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Center(
            child: Text(
              auth.userName.isNotEmpty
                  ? auth.userName[0].toUpperCase()
                  : 'U',
              style: GoogleFonts.inter(
                  color: AppColors.obsidian,
                  fontWeight: FontWeight.w800,
                  fontSize: 34),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(auth.userName,
            style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22)),
        const SizedBox(height: 4),
        Text(auth.userEmail,
            style: GoogleFonts.inter(
                color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.gold.withOpacity(0.35))),
          child: Text(auth.userRole.toUpperCase(),
              style: GoogleFonts.inter(
                  color: AppColors.gold,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ─── INFO CARD ────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final AuthProvider auth;
  const _InfoCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    final rows = [
      [Icons.person_rounded, 'Full Name', auth.userName, false],
      [Icons.email_rounded, 'Email', auth.userEmail, false],
      [Icons.verified_user_rounded, 'Role', auth.userRole, true],
    ];
    return Container(
      decoration: BoxDecoration(
          color: AppColors.inkBlack,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Column(
        children: rows.map((r) {
          final isLast = r[3] as bool;
          return Container(
            decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.border))),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Icon(r[0] as IconData,
                  size: 16, color: AppColors.gold.withOpacity(0.7)),
              const SizedBox(width: 12),
              Text(r[1] as String,
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const Spacer(),
              Text(r[2] as String,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary, fontSize: 13)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─── QUICK LINKS ──────────────────────────────────────────────
class _QuickLinksCard extends StatelessWidget {
  static const _links = [
    [Icons.dataset_rounded,   'Browse Datasets',    '/datasets'],
    [Icons.document_scanner,  'OCR Service',         '/ocr'],
    [Icons.dashboard_rounded, 'Dashboard',           '/dashboard'],
    [Icons.analytics_rounded, 'Analytics',           '/analytics'],
  ];

  @override
  Widget build(BuildContext context) {
    return _LinkSection(title: 'Quick Links', links: _links);
  }
}

// ─── INTERNATIONAL LINKS ──────────────────────────────────────
class _InternationalLinksCard extends StatelessWidget {
  static const _links = [
    [Icons.monitor_heart_rounded, 'Health Indicators',  '/indicators'],
    [Icons.map_rounded,           'Disease Burden Map', '/disease-map'],
    [Icons.menu_book_rounded,     'Publications',       '/publications'],
    [Icons.request_page_rounded,  'Data Request & API', '/data-request'],
    [Icons.science_rounded,       'About & Methodology','/about'],
  ];

  @override
  Widget build(BuildContext context) {
    return _LinkSection(title: 'International Features', links: _links);
  }
}

class _LinkSection extends StatelessWidget {
  final String title;
  final List<List<Object>> links;
  const _LinkSection({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1.2)),
      ),
      Container(
        decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(
          children: links.asMap().entries.map((entry) {
            final i = entry.key;
            final link = entry.value;
            final isLast = i == links.length - 1;
            return Container(
              decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.border))),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(link[0] as IconData,
                      color: AppColors.textSecondary, size: 18),
                ),
                title: Text(link[1] as String,
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.textMuted),
                onTap: () =>
                    Navigator.pushNamed(context, link[2] as String),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}
