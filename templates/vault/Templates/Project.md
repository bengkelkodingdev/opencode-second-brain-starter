---
project: "{{PROJECT_NAME}}"
status: "{{PROJECT_STATUS}}"
code_paths:
  - '{{ABSOLUTE_CODE_PATH}}'
---

# {{PROJECT_NAME}}

{{PROJECT_SUMMARY}}

## Stack

- {{PROJECT_STACK}}

## Referensi

- [[{{PROJECT_NAME}}/_log]] - catatan kronologis append-only

## Catatan

- Semua `code_paths` wajib berupa path absolut.
- Jika path mengandung apostrof (`'`), tulis sebagai dua apostrof (`''`) agar tetap valid dalam YAML.
- Jangan simpan password, token, API key, private key, isi `.env`, atau secret lain.
