// Відповідь AI на базовий промпт без ролі:
// "Напиши віджет картки профілю користувача для Flutter-застосунку:
//  фото, ім'я, email, телефон, місто."
// Код залишено як його згенерувала модель, змінено тільки імпорт.
import 'package:material_ui/material_ui.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String city;
  final String photoUrl;

  ProfileCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(photoUrl),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.grey[700])),
                Text(phone, style: TextStyle(color: Colors.grey[700])),
                Text(city, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
