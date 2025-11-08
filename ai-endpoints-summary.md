# Resumen - Endpoints de IA

## 🚀 Endpoints Disponibles

### 1. Generar Informe de Bitácora
**POST** `/api/v1/obras/{obraId}/bitacoras/generar-informe-ia`

Genera un informe HTML profesional usando IA con toda la información de la obra.

### 2. Chat con IA
**POST** `/api/v1/obras/{obraId}/bitacoras/chat`

Haz preguntas sobre la obra y recibe respuestas inteligentes.

---

## 📋 Request Básico

### Headers
```
Authorization: Bearer {token}
Content-Type: application/json
```

### Generar Informe
```json
{
  "actividades": ["Actividad 1", "Actividad 2"],
  "avanceGeneral": 76,
  "clima": "Soleado, 25°C",
  "observaciones": "Texto opcional"
}
```

### Chat
```json
{
  "mensaje": "¿Cuántos materiales tiene esta obra?"
}
```

---

## 📤 Response

### Generar Informe
```json
{
  "success": true,
  "data": {
    "html": "<div>...</div>",
    "tokensUsados": 2244
  }
}
```

### Chat
```json
{
  "success": true,
  "data": {
    "respuesta": "Esta obra tiene 7 materiales...",
    "tokensUsados": 456
  }
}
```

---

## 📚 Documentación Completa

- **Documentación Detallada**: Ver [ai-endpoints.md](./ai-endpoints.md)
- **Guía de Flutter**: Ver [ai-flutter-guide.md](./ai-flutter-guide.md)

---

## ⚠️ Errores Comunes

| Código | Mensaje | Solución |
|--------|---------|----------|
| 401 | Unauthorized | Verificar token |
| 403 | Forbidden | Usuario sin acceso a la obra |
| 404 | Not Found | Obra no existe |
| 429 | Rate Limit | Esperar unos minutos |
| 500 | Cuota agotada | Revisar facturación OpenAI |

---

## 🔗 Enlaces Útiles

- Swagger: `http://localhost:3000/docs`
- Postman Collection: `postman_collection.json`

