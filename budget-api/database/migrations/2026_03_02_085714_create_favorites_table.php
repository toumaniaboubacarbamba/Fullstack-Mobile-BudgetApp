<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('favorites', function (Blueprint $table) {
            $table->id();
            //lié à l'utilisateur connecté
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            // infos du films
            $table->string('movie_id');
            $table->string('title');
            $table->string('overview')->nullable();
            $table->string('poster_path')->nullable();
            $table->string('vote_average')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'movie_id']); // pour éviter les doublons
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('favorites');
    }
};
