FROM golang:1o.22-alpine AS builder
# Указываем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем файлы go.mod и go.sum для установки зависимостей
COPY go.mod go.sum ./
# Скачиваем зависимости проекта
RUN go mod download
# Копируем весь исходный код проекта в контейнер
COPY . .
# Собираем бинарник приложения для Linux (amd64), без использования CGO
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app

FROM alpine:3.18
# Устанавливаем сертификаты, необходимые для HTTPS
RUN apk add --no-cache ca-certificates
# Указываем рабочую директорию для runtime
WORKDIR /app
# Копируем собранный бинарник
COPY --from=builder /app/app .
# Документируем порт, на котором будет слушать приложение
EXPOSE 8080
# Команда запуска контейнера
CMD ["./app"]
