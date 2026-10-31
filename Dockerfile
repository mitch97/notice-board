# Bacheca online: solo nginx che serve la pagina e la copia in sola lettura dei diari (cartella progetti/).
FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY bacheca.html /usr/share/nginx/html/index.html
COPY bacheca.ico /usr/share/nginx/html/favicon.ico
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
