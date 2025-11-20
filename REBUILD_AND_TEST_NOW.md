# ⚡ REBUILD DAN TEST SEKARANG

## 🚀 Langkah-Langkah (3 Menit)

### Step 1: Bersihkan dan Build Ulang

```bash
cd "d:/Pemrograman Mobile/bloom App/bayujois_app"
flutter clean
flutter pub get
flutter run -v
```

Tunggu sampai app muncul di emulator/device.

---

### Step 2: Quick Test (Add Product)

```
1. Login dengan user apapun
2. Tap: Product Management (tab paling bawah)
3. Tap: + button (floating action button)
4. Isi form:
   - Name: Test Product
   - Price: 50000
   - Stock: 5
5. Tap: Save Product
```

**LIHAT CONSOLE** untuk messages:
```
[DEBUG] Adding product: Test Product (ID: 1)
[DEBUG] Product saved to database: Test Product
[DEBUG] Product added to memory. Total products: 1
```

✅ **Jika ada message di atas = BERHASIL!**

❌ **Jika ada [ERROR] = Masih ada masalah**

---

### Step 3: Test Stock Update

```
1. Tap product yang baru dibuat
2. Tap + button untuk tambah stock
3. Lihat console
```

**LIHAT CONSOLE** untuk messages:
```
[DEBUG] Updating stock for product ID: 1, change: 1
[DEBUG] New stock: 6
[DEBUG] Stock updated in database
```

✅ **Jika ada message di atas = BERHASIL!**

---

### Step 4: Test Persistence (Penting!)

```
1. Close app (swipe away completely)
2. Buka app lagi
3. Go to Product Management
4. Cek apakah product masih ada dengan stock yang sama
```

✅ **Jika product masih ada = DATABASE BERHASIL SIMPAN!**

❌ **Jika hilang/reset = Masih ada bug**

---

## 📸 Jika Ada Error

Jika melihat `[ERROR]` di console:

1. **Screenshot konsol error-nya**
2. **Salin teks error lengkap**
3. **Bagikan di sini**

Contoh error:
```
[ERROR] Error adding product: database is locked
[ERROR] Error updating stock: product not found
```

---

## ✅ Checklist Keberhasilan

- [ ] App rebuild tanpa error
- [ ] Bisa add product (tidak ada error)
- [ ] Console menunjukkan [DEBUG] messages
- [ ] Product muncul di list
- [ ] Stock bisa ditambah/dikurang
- [ ] Data persists setelah close dan reopen app
- [ ] Tidak ada [ERROR] messages

---

**SEKARANG COBA LANGKAH 1-4 DI ATAS, LALU LAPOR HASILNYA!**
