// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/weather_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/weather_painters.dart';
import '../controllers/home_controller.dart';
import '../controllers/weather_controller.dart';
import '../widgets/ai_assistant_sheet.dart';

class HomeScreen extends StatefulWidget {
  final WeatherInfo weather;
  final bool isDetail;
  const HomeScreen({super.key, required this.weather, this.isDetail = false});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeController _homeController;
  final WeatherController _weatherCtrl = Get.find<WeatherController>();

  @override
  void initState() {
    super.initState();
    _homeController = HomeController(vsync: this, weather: widget.weather);
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    return FadeTransition(
      opacity: _homeController.fadeIns[index],
      child: SlideTransition(position: _homeController.slideIns[index], child: child),
    );
  }

  void _showAIAssistant(WeatherInfo currentW) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantSheet(weather: currentW),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Ưu tiên dữ liệu từ API, nếu chưa có thì dùng dữ liệu demo
      final w = _weatherCtrl.weather.value ?? widget.weather;
      final isNight = w.isNight;
      final isLoading = _weatherCtrl.isLoading.value;

      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: widget.isDetail ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.back, color: isNight ? Colors.white : AppColors.bg0),
            onPressed: () => Navigator.pop(context),
          ),
        ) : null,
        floatingActionButton: isLoading ? null : Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: FloatingActionButton.extended(
            onPressed: () => _showAIAssistant(w),
            backgroundColor: AppColors.accent,
            icon: const Icon(CupertinoIcons.sparkles, color: Colors.white),
            label: Text('Hỏi AI', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.getScreenGradient(isNight)),
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => _weatherCtrl.fetchCurrentWeather(w.cityName),
              color: AppColors.accent,
              backgroundColor: isNight ? AppColors.bg1 : Colors.white,
              edgeOffset: 20,
              child: isLoading 
                ? const Center(child: CupertinoActivityIndicator(radius: 15))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHero(w)),
                      SliverToBoxAdapter(child: _buildSmartTips(w)),
                      SliverToBoxAdapter(child: _buildInfoCards(w)),
                      SliverToBoxAdapter(child: _buildMinMaxBar(w)),
                      SliverToBoxAdapter(child: _buildHourlySection()),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      SliverToBoxAdapter(child: _build7DayForecast()),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHero(WeatherInfo w) {
    final isNight = w.isNight;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            (isNight ? AppColors.accent : Colors.white).withValues(alpha: 0.12),
            Colors.transparent
          ],
        ),
      ),
      child: Column(
        children: [
          _staggered(0, _buildCityHeader(w)),
          const SizedBox(height: 4),
          _staggered(1, StreamBuilder<DateTime>(
            stream: _homeController.timeStream,
            initialData: _homeController.now,
            builder: (context, snapshot) => Text(
              _homeController.getFormattedDate(snapshot.data!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isNight ? AppColors.text2 : AppColors.bg0.withValues(alpha: 0.7), 
                fontWeight: isNight ? FontWeight.w400 : FontWeight.w600,
                letterSpacing: 0.4
              ),
            ),
          )),
          const SizedBox(height: 24),
          Hero(
            tag: 'weather-icon-${w.cityName}',
            child: WeatherAnimation(condition: w.condition, size: 220),
          ),
          const SizedBox(height: 12),
          _staggered(3, _buildTempDisplay(w)),
          const SizedBox(height: 6),
          _staggered(4, _buildDescription(w)),
        ],
      ),
    );
  }

  Widget _buildCityHeader(WeatherInfo w) {
    final isNight = w.isNight;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.location_solid, 
          color: isNight ? AppColors.accent : AppColors.bg0, size: 18),
        const SizedBox(width: 6),
        Text(
          w.cityName, 
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: isNight ? AppColors.text1 : AppColors.bg0,
            fontWeight: FontWeight.w800
          )
        ),
        const SizedBox(width: 8),
        _buildLiveBadge(w),
      ],
    );
  }

  Widget _buildLiveBadge(WeatherInfo w) {
    final isNight = w.isNight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isNight ? AppColors.accent : AppColors.bg0).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isNight ? AppColors.accent : AppColors.bg0).withValues(alpha: 0.3)),
      ),
      child: Text('LIVE', style: GoogleFonts.nunito(
        fontSize: 9, fontWeight: FontWeight.w800, 
        color: isNight ? AppColors.accentLight : AppColors.bg0, 
        letterSpacing: 1.2
      )),
    );
  }

  Widget _buildSmartTips(WeatherInfo w) {
    final tips = w.smartTips;
    final isNight = w.isNight;
    return _staggered(5, Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: isNight 
                ? AppTheme.glassBox() 
                : BoxDecoration(
                    color: tip.$3.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tip.$3.withValues(alpha: 0.3)),
                  ),
            child: Row(
              children: [
                Icon(tip.$1, color: tip.$3, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.$2,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isNight ? AppColors.text1 : AppColors.bg0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    ));
  }

  Widget _buildTempDisplay(WeatherInfo w) {
    final isNight = w.isNight;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${w.temperature.toInt()}', 
          style: GoogleFonts.outfit(
            fontSize: 88, 
            fontWeight: FontWeight.w200, 
            color: isNight ? AppColors.text1 : AppColors.bg0, 
            letterSpacing: -4, 
            height: 1
          )
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('°C', style: GoogleFonts.outfit(
            fontSize: 32, fontWeight: FontWeight.w300, 
            color: isNight ? AppColors.accentLight : AppColors.bg0.withValues(alpha: 0.6), 
            letterSpacing: -1
          )),
        ),
      ],
    );
  }

  Widget _buildDescription(WeatherInfo w) {
    final isNight = w.isNight;
    final primaryColor = isNight ? AppColors.text1 : AppColors.bg0;
    final secondaryColor = isNight ? AppColors.text2 : AppColors.bg0.withValues(alpha: 0.7);
    return RichText(
      text: TextSpan(
        style: GoogleFonts.nunito(fontSize: 14, color: secondaryColor, fontWeight: isNight ? FontWeight.w400 : FontWeight.w600),
        children: [
          TextSpan(text: w.description, 
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: primaryColor)),
          const TextSpan(text: '   ·   Cảm giác như '),
          TextSpan(text: '${w.feelsLike.toInt()}°C', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, 
            color: isNight ? AppColors.accentLight : Colors.blue.shade900)),
        ],
      ),
    );
  }

  Widget _buildInfoCards(WeatherInfo w) {
    final isNight = w.isNight;
    final items = [
      (CupertinoIcons.drop_fill, 'ĐỘ ẨM', '${w.humidity}', '%', AppColors.rain),
      (CupertinoIcons.wind, 'GIÓ', '${w.windSpeed.toInt()}', ' km/h', Colors.blueGrey),
      (CupertinoIcons.sun_min_fill, 'UV', '${w.uvIndex}', ' / 10', AppColors.warm),
    ];
    return _staggered(5, Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: items.asMap().entries.map((e) {
          final i = e.value;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: isNight ? AppTheme.glassBox() : _dayNormalBox(),
                child: Column(children: [
                  Icon(i.$1, size: 24, color: i.$5),
                  const SizedBox(height: 8),
                  Text(i.$2, style: GoogleFonts.nunito(
                    fontSize: 9, fontWeight: FontWeight.w800, 
                    color: isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.5), 
                    letterSpacing: 1.0
                  )),
                  const SizedBox(height: 5),
                  Text('${i.$3}${i.$4}', style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w600, 
                    color: isNight ? AppColors.text1 : AppColors.bg0
                  )),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildMinMaxBar(WeatherInfo w) {
    final isNight = w.isNight;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: isNight ? AppTheme.glassBox() : _dayNormalBox(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _tempStat(CupertinoIcons.arrow_down_circle_fill, 'Thấp nhất', '${w.tempMin.toInt()}°', Colors.blue, w),
            Container(width: 1, height: 32, color: isNight ? AppColors.glassBorder : AppColors.bg0.withValues(alpha: 0.1)),
            _tempStat(CupertinoIcons.thermometer, 'Hiện tại', '${w.temperature.toInt()}°', AppColors.warm, w),
            Container(width: 1, height: 32, color: isNight ? AppColors.glassBorder : AppColors.bg0.withValues(alpha: 0.1)),
            _tempStat(CupertinoIcons.arrow_up_circle_fill, 'Cao nhất', '${w.tempMax.toInt()}°', Colors.redAccent, w),
          ],
        ),
      ),
    );
  }

  Widget _tempStat(IconData icon, String label, String val, Color iconColor, WeatherInfo w) {
    final isNight = w.isNight;
    return Column(children: [
      Icon(icon, size: 18, color: iconColor),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.nunito(
        fontSize: 10, 
        color: isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.6), 
        fontWeight: FontWeight.w700
      )),
      const SizedBox(height: 2),
      Text(val, style: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w600, 
        color: isNight ? AppColors.text1 : AppColors.bg0
      )),
    ]);
  }

  Widget _buildHourlySection() {
    final hourly = WeatherData.hourlyForecasts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('DỰ BÁO THEO GIỜ'),
        SizedBox(
          height: 128,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) => _hourlyCard(hourly[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final isNight = _weatherCtrl.weather.value?.isNight ?? true;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(children: [
        Text(title, style: GoogleFonts.nunito(
          fontSize: 10, fontWeight: FontWeight.w800, 
          color: isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.6), 
          letterSpacing: 1.5
        )),
        const Spacer(),
        TapScale(onTap: () {}, child: Text('Xem thêm', style: GoogleFonts.nunito(
          fontSize: 12, fontWeight: FontWeight.w700, 
          color: isNight ? AppColors.accent : Colors.blue.shade900
        ))),
      ]),
    );
  }

  Widget _hourlyCard(HourlyForecast h) {
    final isNight = _weatherCtrl.weather.value?.isNight ?? true;
    final textColor = isNight ? AppColors.text1 : AppColors.bg0;

    return TapScale(
      onTap: () {},
      scale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 74,
        decoration: h.isNow 
            ? (isNight ? AppTheme.glassBoxHighlight() : _dayHighlightBox()) 
            : (isNight ? AppTheme.glassBox() : _dayNormalBox()),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(h.time, style: GoogleFonts.nunito(
              fontSize: 10, fontWeight: FontWeight.w700, 
              color: h.isNow 
                ? (isNight ? AppColors.accentLight : Colors.blue.shade900) 
                : (isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.5))
            )),
            Icon(h.condition.icon, size: 26, color: h.condition.color),
            Text('${h.temperature.toInt()}°', style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w600, color: textColor
            )),
          ],
        ),
      ),
    );
  }

  Widget _build7DayForecast() {
    final daily = WeatherData.dailyForecasts;
    final isNight = _weatherCtrl.weather.value?.isNight ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'DỰ BÁO 7 NGÀY',
            style: GoogleFonts.nunito(
              fontSize: 10, fontWeight: FontWeight.w800, 
              color: isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.6), 
              letterSpacing: 1.5
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: isNight ? AppTheme.glassBox() : _dayNormalBox(),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daily.length,
              separatorBuilder: (_, __) => Divider(
                color: isNight ? AppColors.glassBorder : AppColors.bg0.withValues(alpha: 0.1),
                height: 1, indent: 15, endIndent: 15,
              ),
              itemBuilder: (ctx, i) => _dailyRow(daily[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dailyRow(DailyForecast d) {
    final isNight = _weatherCtrl.weather.value?.isNight ?? true;
    final textColor = isNight ? AppColors.text1 : AppColors.bg0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              d.day,
              style: GoogleFonts.nunito(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(d.condition.icon, size: 22, color: d.condition.color),
                const SizedBox(width: 8),
                Text(
                  d.condition.label,
                  style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: isNight ? FontWeight.w400 : FontWeight.w600,
                    color: isNight ? AppColors.text2 : AppColors.bg0.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${d.tempMax.toInt()}°',
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w600, color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${d.tempMin.toInt()}°',
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w400, 
                    color: isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _dayNormalBox() => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.35),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
  );

  BoxDecoration _dayHighlightBox() => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.75),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
    boxShadow: [
      BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
    ]
  );
}
