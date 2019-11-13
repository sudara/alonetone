# Troubleshooting development

```
NoMethodError: private method `upload' called for nil:NilClass
```

1. Make sure you have `config/alonetone.yml`
2. Set `storage_service` to any key defined in `config/storage.yml`

```
development:
  storage_service: filesystem
```
