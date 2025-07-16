<?php

use App\Http\Controllers\TasksController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


//task api
Route::get('/tasks', [TasksController::class, 'GetAllDataTask']);
Route::post('/tasks', [TasksController::class, 'CreateTask']);
Route::get('/tasks/{id}', [TasksController::class, 'GetDataTaskById']);
Route::put('/tasks/{id}', [TasksController::class, 'UpdateTask']);
Route::delete('/tasks/{id}', [TasksController::class, 'DeleteTask']);
