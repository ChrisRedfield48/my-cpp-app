# ---- Этап 1: Сборка приложения ----
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Копируем исходники и собираем
COPY CMakeLists.txt .
COPY src ./src

RUN mkdir build && cd build && \
    cmake .. -DBUILD_TESTS=OFF && \
    cmake --build . --target my_app

# ---- Этап 2: Минимальный образ для запуска ----
FROM ubuntu:22.04

# Устанавливаем runtime-зависимости
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Создаём непривилегированного пользователя
RUN useradd --create-home appuser
WORKDIR /home/appuser

# Копируем скомпилированный бинарник
COPY --from=builder /app/build/my_app .

USER appuser

CMD ["./my_app"]
