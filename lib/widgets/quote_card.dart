import 'package:flutter/material.dart';
import '../models/quote_model.dart';

/// QuoteCard - displays a motivational quote with author and a refresh button
class QuoteCard extends StatelessWidget {
  final QuoteModel? quote;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const QuoteCard({
    super.key,
    this.quote,
    required this.isLoading,
    this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote,
                color: Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Inspiration',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Refresh quote button
              GestureDetector(
                onTap: isLoading ? null : onRefresh,
                child: AnimatedRotation(
                  turns: isLoading ? 1 : 0,
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quote content area
          if (isLoading)
            _buildLoading()
          else if (error != null)
            _buildError(error!)
          else if (quote != null)
            _buildQuoteContent(quote!)
          else
            _buildLoading(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerBar(1.0, 14),
        const SizedBox(height: 8),
        _shimmerBar(0.8, 14),
        const SizedBox(height: 12),
        _shimmerBar(0.4, 12),
      ],
    );
  }

  Widget _shimmerBar(double widthFactor, double height) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildError(String errorMsg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Could not load quote.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          errorMsg,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteContent(QuoteModel q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${q.content}"',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 24,
              height: 2,
              color: Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              q.author,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
