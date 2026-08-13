// ─── Loading Overlay, Category Grid, Stats Bar, Privacy Badge ─────────────────
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Loading Overlay ──────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black38,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Category Grid ────────────────────────────────────────────────────────────
class CategoryGrid extends StatefulWidget {
  final List<String> categories;
  final Function(String) onSelected;
  final Color headerColor;
  final String headerTitle;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onSelected,
    required this.headerColor,
    required this.headerTitle,
  });

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: widget.headerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.headerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color:      Colors.white,
              fontWeight: FontWeight.w700,
              fontSize:   16,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   2,
            crossAxisSpacing: 12,
            mainAxisSpacing:  12,
            childAspectRatio: 2.4,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            final cat = widget.categories[index];
            final isSelected = _selected == cat;
            return GestureDetector(
              onTap: () {
                setState(() => _selected = cat);
                widget.onSelected(cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:        isSelected ? widget.headerColor.withOpacity(0.15) : AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? widget.headerColor : const Color(0xFFCFD8DC),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:       Colors.black.withOpacity(0.06),
                      blurRadius:  6,
                      offset:      const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize:   13,
                      color:      isSelected ? widget.headerColor : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Stats Bar ────────────────────────────────────────────────────────────────
class StatsBar extends StatelessWidget {
  final int total;
  final int inProgress;
  final int resolved;

  const StatsBar({
    super.key,
    required this.total,
    required this.inProgress,
    required this.resolved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(count: total,      label: 'Total\nSubmissions', icon: Icons.description_outlined,  color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        _StatItem(count: inProgress, label: 'In\nProgress',       icon: Icons.hourglass_empty_rounded, color: AppColors.pending),
        const SizedBox(width: 8),
        _StatItem(count: resolved,   label: 'Resolved',            icon: Icons.check_box_outlined,     color: AppColors.greenCard),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize:   18,
                color:      color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color:    AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

