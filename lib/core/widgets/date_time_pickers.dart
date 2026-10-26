import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class IOSGlassPickers {
  /// Shows a premium frosted glass iOS Date Picker wheel modal
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String title = 'Select Date',
  }) async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime tempDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (modalCtx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              height: 330,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C1E).withValues(alpha: 0.94)
                    : const Color(0xFFF2F2F7).withValues(alpha: 0.94),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // iOS drag pill
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),

                  // Header bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(modalCtx),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : Colors.black.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(modalCtx, tempDate);
                          },
                          child: Text(
                            'Done',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),

                  // Cupertino Date Wheel Picker
                  Expanded(
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness:
                            isDark ? Brightness.dark : Brightness.light,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: GoogleFonts.inter(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: tempDate,
                        minimumDate: firstDate,
                        maximumDate: lastDate,
                        onDateTimeChanged: (newDate) {
                          tempDate = newDate;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows a premium frosted glass iOS Time Picker wheel modal
  static Future<TimeOfDay?> showTimePicker(
    BuildContext context, {
    required TimeOfDay initialTime,
    String title = 'Select Time',
  }) async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    DateTime tempDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      initialTime.hour,
      initialTime.minute,
    );

    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (modalCtx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              height: 330,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C1E).withValues(alpha: 0.94)
                    : const Color(0xFFF2F2F7).withValues(alpha: 0.94),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // iOS drag pill
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),

                  // Header bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(modalCtx),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : Colors.black.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(modalCtx, tempDateTime);
                          },
                          child: Text(
                            'Done',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),

                  // Cupertino Time Wheel Picker
                  Expanded(
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness:
                            isDark ? Brightness.dark : Brightness.light,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: GoogleFonts.inter(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: tempDateTime,
                        onDateTimeChanged: (newDateTime) {
                          tempDateTime = newDateTime;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      return TimeOfDay(hour: selected.hour, minute: selected.minute);
    }
    return null;
  }
}
