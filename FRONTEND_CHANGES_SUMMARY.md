# 📋 Resumen de Cambios API - Frontend

## ✅ Compatibilidad: 100% Retrocompatible

**No se requieren cambios obligatorios.** Todo sigue funcionando igual.

---

## 🆕 Nuevas Funcionalidades

### Bitácoras

1. **Campo nuevo en respuestas:** `generada_por_ia: boolean`
   - Aparece en todas las respuestas
   - Puedes ignorarlo o usarlo para mostrar un badge

2. **Filtro opcional:** `GET /bitacoras?generada_por_ia=true`
   - Sin parámetro = todas (comportamiento anterior)
   - `true` = solo IA
   - `false` = solo manuales

3. **Endpoint generar-informe-ia:** Ahora retorna también `data.bitacora`
   - Puedes seguir usando solo `data.html` como antes

### Materiales

1. **Campos opcionales nuevos en requests:**
   - `cantidad_disponible?: number`
   - `cantidad_requerida?: number`
   - `estado?: 'pendiente' | 'comprado' | 'en_transito' | 'disponible'`

2. **Campos nuevos en respuestas:**
   - `cantidad_faltante: number` (calculado automáticamente)
   - Los campos enviados en el request también aparecen en la respuesta

---

## 📝 Interfaces TypeScript

```typescript
// Bitácoras
interface Bitacora {
  // ... campos existentes
  generada_por_ia: boolean;  // ← NUEVO
}

// Materiales
interface Material {
  // ... campos existentes
  cantidad_disponible?: number;  // ← NUEVO
  cantidad_requerida?: number;    // ← NUEVO
  cantidad_faltante: number;      // ← NUEVO (calculado)
  estado?: 'pendiente' | 'comprado' | 'en_transito' | 'disponible';  // ← NUEVO
}
```

---

## 🎯 Acción Requerida

**Ninguna.** Todo es opcional y retrocompatible.

Si quieres aprovechar las nuevas funcionalidades:
- Muestra badge "Generada por IA" en bitácoras
- Agrega filtro por tipo en lista de bitácoras
- Muestra estado y cantidad faltante en materiales
- Permite editar campos de seguimiento en formulario de materiales

---

**Documentación completa:** Ver `FRONTEND_CHANGES.md`

