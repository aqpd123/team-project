import 'package:flutter/material.dart';

class CelebrityData {
  const CelebrityData({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.profession,
    required this.element,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String birthDate;
  final String profession;
  final String element;
  final String imageUrl;
}

class ElementFilter {
  const ElementFilter({
    required this.name,
    required this.circleColor,
    required this.gradient,
  });

  final String name;
  final Color circleColor;
  final List<Color> gradient;
}

const _elements = [
  ElementFilter(
    name: '화',
    circleColor: Color(0xFFF87171),
    gradient: [Color(0xFFEF4444), Color(0xFFF97316)],
  ),
  ElementFilter(
    name: '수',
    circleColor: Color(0xFF38BDF8),
    gradient: [Color(0xFF0EA5E9), Color(0xFF22D3EE)],
  ),
  ElementFilter(
    name: '목',
    circleColor: Color(0xFF34D399),
    gradient: [Color(0xFF10B981), Color(0xFF059669)],
  ),
  ElementFilter(
    name: '금',
    circleColor: Color(0xFF94A3B8),
    gradient: [Color(0xFF9CA3AF), Color(0xFF475569)],
  ),
  ElementFilter(
    name: '토',
    circleColor: Color(0xFFFACC15),
    gradient: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  ),
];

const _celebrities = [
  CelebrityData(
    id: '1',
    name: 'BTS 정국',
    birthDate: '1997-09-01',
    profession: '가수',
    element: '목',
    imageUrl:
        'https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20style%20Korean%20male%20idol%20singer%2C%20handsome%20young%20man%20with%20dark%20hair%2C%20vibrant%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame&width=100&height=100&seq=jungkook-icon&orientation=squarish',
  ),
  CelebrityData(
    id: '2',
    name: '아이유',
    birthDate: '1993-05-16',
    profession: '가수',
    element: '화',
    imageUrl:
        'https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20style%20Korean%20female%20singer%2C%20beautiful%20young%20woman%20with%20long%20dark%20hair%2C%20vibrant%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame&width=100&height=100&seq=iu-icon&orientation=squarish',
  ),
  CelebrityData(
    id: '3',
    name: '박서준',
    birthDate: '1988-12-16',
    profession: '배우',
    element: '토',
    imageUrl:
        'https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20style%20Korean%20male%20actor%2C%20handsome%20man%20with%20stylish%20hair%2C%20vibrant%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame&width=100&height=100&seq=seojun-icon&orientation=squarish',
  ),
  CelebrityData(
    id: '4',
    name: '송혜교',
    birthDate: '1981-11-22',
    profession: '배우',
    element: '금',
    imageUrl:
        'https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20style%20Korean%20female%20actress%2C%20elegant%20woman%20with%20beautiful%20features%2C%20vibrant%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame&width=100&height=100&seq=hyekyo-icon&orientation=squarish',
  ),
  CelebrityData(
    id: '5',
    name: '손흥민',
    birthDate: '1992-07-08',
    profession: '축구선수',
    element: '수',
    imageUrl:
        'https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20style%20Korean%20male%20soccer%20player%2C%20athletic%20man%20in%20sports%20uniform%2C%20vibrant%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame&width=100&height=100&seq=sonny-icon&orientation=squarish',
  ),
  CelebrityData(
    id: '6',
    name: '김연아',
    birthDate: '1990-09-05',
    profession: '피겨스케이팅',
    element: '목',
    imageUrl:
        'https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20style%20Korean%20female%20figure%20skater%2C%20graceful%20woman%20in%20skating%20outfit%2C%20vibrant%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame&width=100&height=100&seq=yuna-icon&orientation=squarish',
  ),
];

/// React `celebrity-saju/page.tsx`의 Flutter 버전.
/// element 선택 → 유명인 목록 → 외부 콜백으로 결과 화면 이동 흐름을 복제했다.
class CelebritySajuPage extends StatefulWidget {
  const CelebritySajuPage({
    super.key,
    this.onBackToRoot,
    this.onCelebritySelected,
  });

  final VoidCallback? onBackToRoot;
  final ValueChanged<CelebrityData>? onCelebritySelected;

  @override
  State<CelebritySajuPage> createState() => _CelebritySajuPageState();
}

class _CelebritySajuPageState extends State<CelebritySajuPage> {
  String? _selectedElement;

  List<CelebrityData> get _filteredCelebs {
    if (_selectedElement == null) return const [];
    return _celebrities
        .where((c) => c.element == _selectedElement)
        .toList(growable: false);
  }

  void _handleBack() {
    if (_selectedElement != null) {
      setState(() {
        _selectedElement = null;
      });
    } else {
      widget.onBackToRoot?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _selectedElement == null
                          ? _buildElementList()
                          : _buildCelebrityList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                  Color(0xFF2E1065),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Image.network(
            'https://readdy.ai/api/search-image?query=mystical%20kawaii%20illustration%20style%2C%20traditional%20Korean%20hanok%20village%20at%20peaceful%20night%20scene%2C%20high%20quality%20detailed%20artwork%2C%20soft%20dreamy%20aesthetic%2C%20cozy%20traditional%20houses%20with%20warm%20glowing%20paper%20lanterns%2C%20majestic%20bright%20full%20moon%20illuminating%20the%20dark%20blue%20starry%20sky%2C%20countless%20twinkling%20stars%20scattered%20across%20the%20heavens%2C%20serene%20reflecting%20pond%20with%20elegant%20small%20stone%20bridge%2C%20misty%20ethereal%20atmosphere%2C%20soft%20pastel%20night%20colors%20with%20deep%20blues%20and%20purples%2C%20traditional%20Korean%20architecture%20with%20curved%20rooftops%2C%20gentle%20mist%20rising%20from%20the%20water%2C%20enchanted%20fairy%20tale%20ambiance%2C%20nostalgic%20vintage%20feel%2C%20mobile%20wallpaper%20vertical%20composition%2C%20mystical%20lighting%20effects%2C%20peaceful%20zen%20garden%20elements&width=375&height=812&seq=mystical-hanok-night&orientation=portrait',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            color: Colors.black.withOpacity(0.2),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final subtitle = _selectedElement == null
        ? '오행별로 유명인과 궁합 보기'
        : '${_selectedElement!} 속성 유명인';
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '유명인과 사주보기 ⭐',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFA5F3FC), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildElementList() {
    return ListView.separated(
      itemCount: _elements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final element = _elements[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedElement = element.name),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: element.circleColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      element.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    element.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrityList() {
    final items = _filteredCelebs;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white24,
              child: Icon(Icons.star_border, color: Colors.white54, size: 40),
            ),
            SizedBox(height: 12),
            Text(
              '유명인이 없어요',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              '다른 속성을 선택해보세요',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
      final celeb = items[index];
      return GestureDetector(
        onTap: () => widget.onCelebritySelected?.call(celeb),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(celeb.imageUrl),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      celeb.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      celeb.profession,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      celeb.birthDate,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
            ],
          ),
        ),
      );
    });
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }
}

