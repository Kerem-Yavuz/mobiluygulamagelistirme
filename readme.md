#  Şikayet Bildirim Uygulaması

Bu mobil uygulama, üniversite kampüsünde karşılaşılan sorunların hızlıca bildirilmesini ve görevlilere iletilmesini amaçlar. Kullanıcılar uygulama üzerinden şikayetlerini oluşturabilir, harita üzerinden konum belirleyebilir ve şikayet detaylarını görüntüleyebilir.

##  Giriş Bilgileri (Test Kullanıcısı)

- **Kullanıcı Adı:** `test@gmail.com`  
- **Şifre:** `123456`

>  Bu bilgiler test amaçlıdır. Gerçek kullanıcılar uygulama üzerinden kayıt olabilir.

---

##  Proje Dosya Yapısı ve Görevleri

| Klasör/Dosya | Açıklama |
|-------------|----------|
| `appbar` | Sayfalar için özelleştirilmiş AppBar bileşeni |
| `base_page` | Tüm sayfalarda kullanılan temel yapı (base widget) |
| `complaints` | Şikayet oluşturma ve listeleme işlemleri |
| `DetailsPage` | Şikayet detaylarını gösteren sayfa |
| `drawer` | Uygulama içinde gezinme sağlayan yan menü |
| `firebase_config` | Firebase yapılandırma ayarları |
| `insert_screen` | Yeni şikayet ekleme ekranı |
| `login_screen` | Kullanıcı giriş ekranı (Supabase ile entegre) |
| `map` | Harita işlemleri için genel yapı |
| `mapPage` | Haritanın ana sayfada gösterildiği yapı |
| `MapWithSinglePoin` | Haritada tek nokta gösterimi |
| `profile` | Kullanıcı profil bilgileri ve görsel güncelleme |
| `settings` | Uygulama ayarları (örneğin tema seçimi) |
| `signup` | Yeni kullanıcı kayıt ekranı |
| `SplashScreen` | Uygulama başlatıldığında açılan ilk ekran |
| `tappable_image` | Harita üzerinde koordinat seçimi için görsel yapı |
| `ThemeNotifier` | Tema yönetimi ve bildirim sistemi |

---

##  Geliştirici Ekibi ve Sorumluluklar

| İsim | Görevler |
|------|---------|
| **Abdullah Kerem Yavuz** | `login_screen`, Supabase entegrasyonu, `profile`, görsel yükleme işlemleri , bugfix |
| **Kerem Yavuz** | `appbar`, `drawer`, `firebase_config`, `base_page`, `map`, `settings`, `signup`, `SplashScreen`, `ThemeNotifier`, Single sign on |
| **Taha İslam Güven** |  `complaints`, `DetailsPage`, `insert_screen`, `mapPage`, `MapWithSinglePoin`, `tappable_image`, Genel düzenleme, |

---

##  Proje Amacı

Bu uygulamanın amacı, kampüs ortamında karşılaşılan fiziksel veya sistemsel problemlerin hızlıca yetkili kişilere bildirilmesini ve takibinin sağlanmasını kolaylaştırmaktır. Harita üzerinden konum belirleme, detaylı açıklama ekleme ve kullanıcı dostu bir arayüz ile süreçler hızlandırılmıştır.

---

##  Kurulum ve Başlatma

1. Projeyi klonlayın:  
   ```bash
   git clone https://github.com/kullaniciadi/sikayet-uygulamasi.git
   cd sikayet-uygulamasi
