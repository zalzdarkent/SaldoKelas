import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saldokelas/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saldokelas/pages/login.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _logout() async {
    bool? shouldLogout = await _showLogoutDialog();

    if (shouldLogout == true) {
      try {
        final response = await http.post(
          ApiConfig.buildUri('user/logout'), 
          headers: {
            'Content-Type': 'application/json',
            // Tambahkan token jika diperlukan
            'Authorization': 'Bearer ${await _getToken()}',
          },
        );

        if (response.statusCode == 200) {
          // Hapus token dari SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');

          // Navigasikan ke halaman login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );

          // Tampilkan pesan sukses
          _showSnackBar('Logout berhasil.');
        } else {
          // Tampilkan pesan error berdasarkan status code
          _showSnackBar(
              'Logout gagal. Error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        // Tangani error jika ada masalah jaringan
        _showSnackBar('Terjadi kesalahan koneksi. Coba lagi.');
      }
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Ambil token dari SharedPreferences
  }

  Future<bool?> _showLogoutDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Pilih Tidak
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Pilih Ya
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SaldoKelas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ringkasan Keuangan Kelas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  // Aksi untuk notifikasi
                },
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app), // Ikon logout
                onPressed: _logout, // Panggil fungsi logout saat ditekan
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ringkasan Kas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Saldo',
                      amount: 'Rp 1.500.000',
                      color: Colors.green,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Input',
                      amount: 'Rp 2.000.000',
                      color: Colors.blue,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Output',
                      amount: 'Rp 500.000',
                      color: Colors.red,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Menu Navigasi
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildMenuCard(
                    context: context,
                    title: 'Tambah Kas',
                    icon: Icons.add,
                    color: Colors.deepPurple,
                    onTap: () {
                      // Navigasi ke halaman Tambah Kas
                    },
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Riwayat Kas',
                    icon: Icons.history,
                    color: Colors.orange,
                    onTap: () {
                      // Navigasi ke halaman Riwayat Kas
                    },
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Pengaturan',
                    icon: Icons.settings,
                    color: Colors.grey,
                    onTap: () {
                      // Navigasi ke halaman Pengaturan
                    },
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Anggota Kelas',
                    icon: Icons.group,
                    color: Colors.teal,
                    onTap: () {
                      // Navigasi ke halaman Anggota Kelas
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Ringkasan Kas
  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                  fontSize: 16, color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Menu Navigasi
  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
