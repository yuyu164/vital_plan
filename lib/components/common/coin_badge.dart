import 'package:flutter/material.dart';
import '../../api/coin_service.dart';

class CoinBadge extends StatefulWidget {
  const CoinBadge({Key? key}) : super(key: key);

  @override
  _CoinBadgeState createState() => _CoinBadgeState();
}

class _CoinBadgeState extends State<CoinBadge> {
  final CoinService _coinService = CoinService();

  @override
  void initState() {
    super.initState();
    // 确保初始化
    _coinService.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _coinService.coinsNotifier,
      builder: (context, coins, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$coins",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 4),
            Image.asset(
              "lib/assets/images/coin/honest_graphic-money-bag-9772256_1920.png",
              width: 24,
              height: 24,
            ),
            SizedBox(width: 12),
          ],
        );
      },
    );
  }
}
