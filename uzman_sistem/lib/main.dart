import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(PetApp());

class PetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Expert System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PetForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PetForm extends StatefulWidget {
  @override
  _PetFormState createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();

  // Default değerler kaldırıldı, hepsi null olacak
  String? allergy;
  String? placeSuitable;
  String? monthlyBudget;
  String? dailyTime;
  String? otherPet;
  String? homeTime;
  String? baby;
  String? travel;
  String? ageRange;

  List<String> pets = [];
  List<String> explanations = []; // Açıklamaları tutmak için yeni liste
  bool _submitted = false;

  Future<void> _submit() async {
    final uri = Uri.parse('http://192.168.124.185:8000/recommend');
    final body = jsonEncode({
      'allergy': allergy,
      'place_suitable': placeSuitable,
      'monthly_budget': monthlyBudget,
      'daily_time': dailyTime,
      'other_pet': otherPet,
      'home_time': homeTime,
      'baby': baby,
      'travel': travel,
      'age_range': ageRange,
    });

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        setState(() {
          if (decoded is List && decoded.isEmpty) {
            pets = ['— Buna uygun öneri bulunamadı. —'];
            explanations = [];
          } else {
            pets = List<String>.from(
              decoded.map(
                (item) =>
                    'Evcil Hayvan: \\${item['pet']} (Puan: \\${item['score']})',
              ),
            );
            explanations = List<String>.from(
              decoded.map(
                (item) => item['explanation'] ?? 'Açıklama bulunamadı',
              ),
            );
          }
          _submitted = true;
        });
      } else {
        setState(() {
          pets = ['— Uygun evcil hayvan bulunamadı —'];
          explanations = [];
        });
      }
    } catch (e) {
      setState(() {
        pets = ['— Sunucuya bağlanılamadı: $e —'];
        explanations = [];
      });
    }
  }

  DropdownButtonFormField<String> buildDropdown(
    String label,
    List<String> items,
    String? currentValue,
    void onChanged(val),
  ) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xFF4F8EF7),
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(Icons.arrow_drop_down, color: Color(0xFF4F8EF7)),
      dropdownColor: Colors.white,
      style: TextStyle(color: Color(0xFF222B45), fontSize: 16),
      items:
          items.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Bu alan zorunlu' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final answers = [
      {'label': 'Alerji', 'value': allergy},
      {'label': 'Yer Uygunluğu', 'value': placeSuitable},
      {'label': 'Aylık Bütçe', 'value': monthlyBudget},
      {'label': 'Günlük Zaman', 'value': dailyTime},
      {'label': 'Başka Evcil Hayvan', 'value': otherPet},
      {'label': 'Evde Kalış Süresi', 'value': homeTime},
      {'label': 'Evde Bebek', 'value': baby},
      {'label': 'Sık Seyahat', 'value': travel},
      {'label': 'Yaş Aralığı', 'value': ageRange},
    ];
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    'Evcil Hayvan Öneri Sistemi',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F8EF7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sana en uygun evcil hayvanı bulmak için birkaç soruya cevap ver!',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 36),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child:
                        !_submitted
                            ? Card(
                              key: ValueKey('form'),
                              elevation: 12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 36,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.quiz,
                                        color: Color(0xFF4F8EF7),
                                        size: 40,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Soruları Doldurun',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4F8EF7),
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      // Soru kartları
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Alerji Var mı?',
                                          ['Evet', 'Hayır'],
                                          allergy,
                                          (v) => setState(() => allergy = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Yer Uygunluğu',
                                          ['Küçük', 'Geniş', 'Farketmez'],
                                          placeSuitable,
                                          (v) =>
                                              setState(() => placeSuitable = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Aylık Bütçe Var mı?',
                                          ['Evet', 'Hayır'],
                                          monthlyBudget,
                                          (v) =>
                                              setState(() => monthlyBudget = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Günlük Zaman',
                                          ['Az', 'Orta', 'Fazla'],
                                          dailyTime,
                                          (v) => setState(() => dailyTime = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Başka Evcil Hayvan Var mı?',
                                          ['Evet', 'Hayır'],
                                          otherPet,
                                          (v) => setState(() => otherPet = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Evde Kalış Süresi',
                                          ['Az', 'Uzun'],
                                          homeTime,
                                          (v) => setState(() => homeTime = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Evde Bebek Var mı?',
                                          ['Evet', 'Hayır'],
                                          baby,
                                          (v) => setState(() => baby = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Sık Seyahat mi?',
                                          ['Evet', 'Hayır'],
                                          travel,
                                          (v) => setState(() => travel = v),
                                        ),
                                      ),
                                      _buildQuestionCard(
                                        buildDropdown(
                                          'Yaş Aralığı',
                                          ['0-12', '13-60', '60+'],
                                          ageRange,
                                          (v) => setState(() => ageRange = v),
                                        ),
                                      ),
                                      SizedBox(height: 28),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              (allergy != null &&
                                                      placeSuitable != null &&
                                                      monthlyBudget != null &&
                                                      dailyTime != null &&
                                                      otherPet != null &&
                                                      homeTime != null &&
                                                      baby != null &&
                                                      travel != null &&
                                                      ageRange != null)
                                                  ? () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      _submit();
                                                    }
                                                  }
                                                  : null,
                                          icon: Icon(
                                            Icons.pets,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Öneri Al',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF4F8EF7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            : Card(
                              key: ValueKey('result'),
                              elevation: 16,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 36,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    bool wide = constraints.maxWidth > 600;
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF4F8EF7),
                                          size: 48,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Sonuçlar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Color(0xFF4F8EF7),
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                        Flex(
                                          direction:
                                              wide
                                                  ? Axis.horizontal
                                                  : Axis.vertical,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Cevaplar sütunu
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Cevaplarınız',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Color(0xFF4F8EF7),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  ...answers.map(
                                                    (a) => Card(
                                                      elevation: 2,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            vertical: 4,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      color: Color(0xFFF8FAFB),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.check,
                                                              color: Color(
                                                                0xFF4F8EF7,
                                                              ),
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              '${a['label']}: ',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${a['value']}',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: wide ? 32 : 0,
                                              height: wide ? 0 : 32,
                                            ),
                                            // Öneriler sütunu
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Önerilen Evcil Hayvanlar',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Color(0xFF4F8EF7),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  ...List.generate(
                                                    pets.length,
                                                    (index) => Card(
                                                      elevation: 4,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      color: Color(0xFFE3EDFC),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          16,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.pets,
                                                                  color: Color(
                                                                    0xFF4F8EF7,
                                                                  ),
                                                                  size: 28,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    pets[index],
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Color(
                                                                        0xFF222B45,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            if (explanations
                                                                    .isNotEmpty &&
                                                                index <
                                                                    explanations
                                                                        .length)
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.only(
                                                                      top: 8,
                                                                    ),
                                                                child: Text(
                                                                  explanations[index],
                                                                  style: TextStyle(
                                                                    color: Color(
                                                                      0xFF6B7280,
                                                                    ),
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 32),
                                        SizedBox(
                                          width: 220,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _submitted = false;
                                                allergy = null;
                                                placeSuitable = null;
                                                monthlyBudget = null;
                                                dailyTime = null;
                                                otherPet = null;
                                                homeTime = null;
                                                baby = null;
                                                travel = null;
                                                ageRange = null;
                                                pets = [];
                                                explanations = [];
                                              });
                                            },
                                            icon: Icon(
                                              Icons.refresh,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              'Tekrar Dene',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF4F8EF7,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Color(0xFFF3F6FD),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}
