# Evcil Hayvan Seçiminde Uzman Sistem

## Proje Amacı
Bu proje, kullanıcıların yaşam koşulları ve bireysel özelliklerine göre en uygun evcil hayvanı belirlemeyi amaçlayan bir uzman sistem (decision support) uygulamasıdır. Hedefimiz, kullanıcıların hem sorumlu hem de sağlıklı bir şekilde hayvan sahiplenme kararı vermelerine yardımcı olmaktır.

## Neden Gerekli?
Yanlış evcil hayvan seçimi, hem hayvan hem de sahip için mutsuzluk, bakım sorunları ve hatta terk edilme riskine yol açabilir. Kullanıcının yaşam biçimine ve önceliklerine uygun hayvan önerilmesi bu riskleri minimize eder.

---

## Uzman Sistem Rolleri
- **Uzman (Evcil Hayvan Bilgi Kaynağı)**  
  Evcil hayvanların bakımı, ihtiyaçları ve uygunluk koşulları hakkında bilgi sağlar.
- **Bilgi Mühendisi**  
  Uzmandan aldığı bilgileri kural tabanına aktarır, karar ağacını ve mantıksal kuralları oluşturur.
- **Proje Yöneticisi**  
  Projeyi planlar, yürütür ve ekip içi koordinasyonu sağlar.
- **Kullanıcı**  
  Uzman sistemi kullanarak soruları yanıtlar ve kendine en uygun evcil hayvanı öneri olarak alır.

---

## Sistem Tasarımı ve Karar Süreci

### 1. Soruların Belirlenmesi
- “Alerji durumu nedir?”, “Günlük zaman ayırma kapasitesi ne kadar?”, “Seyahat sıklığı nedir?” gibi sorular ile başlayan kapsamlı bir anket hazırlandı.
- Kullanıcılardan her kriterin önem derecesini “Çok Önemli / Önemli / Önemsiz / Hiç Önemli Değil” seçeneğiyle puanlamaları istendi:
  - **Çok Önemli**: +2 puan  
  - **Önemli**: +1 puan  
  - **Önemsiz**: –1 puan  
  - **Hiç Önemli Değil**: –2 puan  

### 2. Puanların Hesaplanması ve Ağırlıklandırma
1. Her soru için katılımcıların verdiği cevapların toplanarak **Toplam Puan** hesaplandı.  
   - Örnek: 10 kişi “Çok Önemli” (+2), 5 kişi “Önemli” (+1), 2 kişi “Önemsiz” (–1), 1 kişi “Hiç Önemli Değil” (–2) dediğinde:
     ```
     Toplam Puan = (10 × 2) + (5 × 1) + (2 × –1) + (1 × –2) = 21
     ```
2. Tüm soruların toplam puanı hesaplandıktan sonra, her soru için **Ağırlık (%)** belirlendi:
   Ağırlık (%) = (Soru Toplam Puanı ÷ Tüm Soruların Toplam Puanı) × 100-
   Örnek: Bir soru 32 puan aldıysa ve tüm soruların toplamı 328 puansa:
  ```
  Ağırlık = (32 / 328) × 100 ≈ %9.76
  ```
3. Belirlenen **%7 eşik değeri** altındaki sorular, kullanıcı tercihlerinde belirleyici olmadığı için sistemin karar sürecine dahil edilmedi.

### 3. Karar Mantığı
1. Kullanıcı, **önceden seçilmiş 9 temel soruya** (“Alerji var mı?”, “Günlük zaman ayırabilir mi?”, “Seyahat sıklığı nedir?” vb.) yanıt verir.  
2. Her soru, anket analizinden elde edilen **ağırlık değerine** sahiptir (Örneğin: Alerji durumu %9.76, Yaş aralığı %7.32).  
3. Kullanıcının “Evet”/“Hayır” cevapları, önceden tanımlanmış her hayvan türünün uygunluk koşulları ile kıyaslanır.  
4. İlgili sorunun **ağırlığı** ve “Eşleşme (match)” durumu değerlendirilir.  
5. Her hayvan türü için **uygunluk puanı** hesaplanır:
- Örnek: Kedi için 5 soruda eşleşme var ve bu soruların toplam ağırlığı 43 puan → Kedinin puanı 43 olur.  
6. Tüm sorulara göre her hayvanın toplam puanı hesaplanır ve **en yüksek puana** sahip tür(ler) kullanıcıya önerilir.  
7. Karar, kullanıcıdan alınan yanıtların tümüne dayalıdır; hiçbir kriter tek başına kesin karar vermez.

---

## Uzman Sistem Yapısı

- **Girdi (Input):**  
Kullanıcı, 9 soru için yanıtlarını (Evet / Hayır) sisteme girer.

- **Bilgi Tabanı (Knowledge Base):**  
- Her evcil hayvan türü için uygunluk koşulları (kriter–cevap eşleştirmeleri) önceden tanımlanmıştır.  
- Her kriterin ağırlığı (anket sonucu) bilgi tabanında yer alır.

- **Çıkarım Mekanizması (Inference Engine):**  
- Kullanıcı yanıtları ve bilgi tabanındaki kriterler karşılaştırılır.  
- Eşleşen her kriterin ağırlıkları toplanarak her hayvandan “uygunluk puanı” elde edilir.

- **Çıktı (Output):**  
- En yüksek toplam puana sahip hayvan(lar) öneri olarak kullanıcıya sunulur.  
- Örn: “Kedi (43 puan), Balık (38 puan) ve Papağan (35 puan) uygun seçenekler olarak listelenmiştir.”

---

## Veri Modeli (Evcil Hayvan Özellikleri)
| Alan            | Açıklama                                                                 | Olası Değerler           |
|-----------------|--------------------------------------------------------------------------|--------------------------|
| `id`            | Her hayvana ait benzersiz kimlik numarası                                 | (Tam sayı)               |
| `pet`           | Hayvanın adı                                                            | Örn: “Kedi”, “Köpek”, “Balık” |
| `allergy`       | Alerjisi olan biri için uygun mu? (“Evet” → alerjisi olana uygun)       | “Evet” / “Hayır”         |
| `place_suitable`| Yaşayabileceği alanın büyüklüğü                                          | “Küçük” / “Geniş” / “Farketmez” |
| `monthly_budget`| Aylık bakım maliyetine ilişkin beklenti                                   | “Hayır” (düşük) / “Orta” / “Evet” (yüksek) |
| `daily_time`    | Günlük bakım için gereken minimum zaman miktarı                           | “Az” / “Orta” / “Fazla”  |
| `other_pet`     | Başka bir evcil hayvanla uyumlu mu?                                      | “Evet” (uyumlu) / “Hayır” (uyumsuz) |
| `home_time`     | Kullanıcının evde geçirdiği ortalama zaman                                 | “Az” / “Uzun”            |
| `baby`          | Evde bebek varsa uygun mu?                                               | “Evet” (uygun) / “Hayır” (uygun değil) |
| `travel`        | Kullanıcının seyahat sıklığına uygun mu?                                  | “Evet” (seyahat eden için uygun) / “Hayır” |
| `age_range`     | Hangi yaş grubu için uygun olduğu                                          | Örn: “0-12”, “13-60”, “60+” |

---

## Kullanım Adımları
1. **Anketi Doldurma:**  
Kullanıcı, sistemde listelenen 9 temel soruya Evet/Hayır şeklinde cevap verir.

2. **Puan ve Ağırlık Hesaplama (Ön İşlem):**  
- Her sorunun anket sonuçlarından elde edilen ağırlık değerleri kullanılır.  
- Kullanıcının vereceği her cevap, o sorunun ağırlığı kadar o hayvan için puan getirir veya götürür.

3. **Karar Verme ve Öneri:**  
- Sistem, tüm hayvan türleri için eşleştirme mantığıyla puanları toplar.  
- En yüksek puana sahip tür(ler) kullanıcıya öneri olarak sunulur.

4. **Sonuçların Görüntülenmesi:**  
- Öneri listesi, kategori ve açıklamalarla birlikte kullanıcıya gösterilir.  
- Gerekirse kullanıcı ek kriterleri tekrar düzenleyerek süreci tekrarlayabilir.

---
