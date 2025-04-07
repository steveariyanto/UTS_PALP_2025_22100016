<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;

// Route::get('/products', function () {
//     return response()->json([
//         [
//             'id' => 1,
//             'name' => 'Mango Sagoo',
//             'price' => 25000,
//             'photo' => 'https://foto.kontan.co.id/tsvw7DWpvxweHDDCRx4QhkrQbC4=/smart/2023/09/22/1398596958p.jpg',
//             'is_promo' => true,
//         ],
//         [
//             'id' => 2,
//             'name' => 'Nasi Kuning',
//             'price' => 15000,
//             'photo' => 'https://www.dapurkobe.co.id/wp-content/uploads/nasi-kuning-kobe.jpg',
//             'is_promo' => false,
//         ]        
//     ]);
Route::resource('products', ProductController::class);
