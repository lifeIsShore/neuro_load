import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/session_provider.dart';

class LapFeed extends StatelessWidget {
  final List<Lap> laps;
  const LapFeed({super.key, required this.laps});

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) {
      return Center(
        child: Text(
          'No distractions logged yet.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: laps.length,
      itemBuilder: (context, index) {
        final lap = laps[laps.length - 1 - index]; // newest first
        final timeSinceStart = lap.timestamp;
        final label = '${timeSinceStart.hour.toString().padLeft(2, '0')}:'
            '${timeSinceStart.minute.toString().padLeft(2, '0')}';
        return _LapTile(lap: lap, timeLabel: label);
      },
    );
  }
}

class _LapTile extends StatelessWidget {
  final Lap lap;
  final String timeLabel;

  const _LapTile({required this.lap, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.silverGrayDim,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.silverGray, width: 1),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  lap.trigger.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  lap.trigger.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (lap.note != null && lap.note!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    '— ${lap.note}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            timeLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
