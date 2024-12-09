const express = require('express');
const app = express();
const port = 3000;
const mysql = require('mysql2');

// JSON verisi gönderebilmek için body-parser kullanıyoruz
app.use(express.json());

// MySQL bağlantısını oluşturuyoruz
const db = mysql.createConnection({
  host: 'localhost', // Eğer başka bir sunucuda çalışıyorsa burayı değiştirin
  user: 'root',      // MySQL kullanıcı adı (root olabilir)
  password: '5434340',      // MySQL şifresi
  database: 'ogrenci_db' // Veritabanı adı
});

// Bağlantıyı kontrol ediyoruz
db.connect((err) => {
  if (err) {
    console.error('MySQL bağlantısı sağlanamadı: ' + err.stack);
    return;
  }
  console.log('MySQL bağlantısı başarıyla yapıldı.');
});

// Tüm öğrencileri listeleme (GET)
app.get('/ogrenciler', (req, res) => {
  db.query('SELECT * FROM ogrenci', (err, results) => {
    if (err) {
      return res.status(500).send('Öğrenciler alınamadı');
    }
    res.json(results); // Öğrenci verisini JSON olarak döndür
  });
});

// Yeni öğrenci ekleme (POST)
app.post('/ogrenci', (req, res) => {
  const { ad, soyad, bolumID } = req.body; // Gelen veriyi alıyoruz

  // MySQL'e veri ekleme
  const query = 'INSERT INTO ogrenci (ad, soyad, bolumID) VALUES (?, ?, ?)';
  db.query(query, [ad, soyad, bolumID], (err, result) => {
    if (err) {
      console.error('Veri eklenemedi: ' + err.stack);
      return res.status(500).send('Öğrenci eklenemedi');
    }
    console.log('Yeni öğrenci eklendi:', result);
    res.status(201).json({ ogrenciID: result.insertId, ad, soyad, bolumID });
  });
});

// Öğrenci silme (DELETE)
app.delete('/ogrenci/:id', (req, res) => {
  const id = parseInt(req.params.id); // ID'yi sayıya dönüştürüyoruz
  if (isNaN(id)) {
    return res.status(400).send({ message: 'Geçersiz ID' }); // Geçersiz ID kontrolü
  }

  const query = 'DELETE FROM ogrenci WHERE ogrenciID = ?';
  db.query(query, [id], (err, result) => {
    if (err) {
      console.error('Öğrenci silinemedi: ' + err.stack);
      return res.status(500).send('Öğrenci silinemedi');
    }

    if (result.affectedRows === 0) {
      return res.status(404).send('Öğrenci bulunamadı');
    }

    res.status(200).send('Öğrenci silindi');
  });
});

// Öğrenci güncelleme (PUT)
app.put('/ogrenci/:id', (req, res) => {
  const id = parseInt(req.params.id);
  if (isNaN(id)) {
    return res.status(400).send({ message: 'Geçersiz ID' });
  }

  const { ad, soyad, bolumID } = req.body;

  const query = 'UPDATE ogrenci SET ad = ?, soyad = ?, bolumID = ? WHERE ogrenciID = ?';
  db.query(query, [ad, soyad, bolumID, id], (err, result) => {
    if (err) {
      console.error('Öğrenci güncellenemedi: ' + err.stack);
      return res.status(500).send('Öğrenci güncellenemedi');
    }

    if (result.affectedRows === 0) {
      return res.status(404).send('Öğrenci bulunamadı');
    }

    res.status(200).json({ ogrenciID: id, ad, soyad, bolumID });
  });
});

// Sunucuyu başlatma
app.listen(port, '0.0.0.0', () => {
  console.log(`Sunucu http://0.0.0.0:${port} adresinde çalışıyor.`);
});
