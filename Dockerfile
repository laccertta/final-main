FROM golang:1.24-alpine AS builder
# Указываем рабочую директорию внутри контейнера
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
# Копируем весь исходный код проекта в контейнер
COPY . .
# Собираем бинарник приложения для Linux (amd64), без использования CGO
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app main.go parcel.go

FROM alpine:3.18
# Устанавливаем сертификаты, необходимые для HTTPS
RUN apk add --no-cache ca-certificates
# Указываем рабочую директорию для runtime
WORKDIR /app
# Копируем собранный бинарник
COPY --from=builder /app/app .
COPY tracker.db .
# Документируем порт, на котором будет слушать приложение
EXPOSE 8080
# Команда запуска контейнера
CMD ["./app"]
