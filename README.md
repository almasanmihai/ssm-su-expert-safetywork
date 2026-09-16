# SSM & SU Expert SafetyWork — site de prezentare

Site static (Astro) pentru prezentarea serviciilor SSM / SU.

## Preview live

După primul push pe `main` și activarea GitHub Pages:

**https://almasanmihai.github.io/ssm-su-expert-safetywork/**

(URL-ul final depinde de userul/organizația GitHub unde e repo-ul.)

## Local

```sh
npm install
npm run dev
```

Deschide `http://localhost:4321/ssm-su-expert-safetywork/`.

## Build

```sh
npm run build
npm run preview
```

## Deploy

Fiecare push pe `main` pornește workflow-ul `.github/workflows/deploy.yml` și publică pe GitHub Pages.

În Settings → Pages al repo-ului, sursa trebuie să fie **GitHub Actions**.

## Structură

- `/` — Acasă
- `/servicii` — Servicii SSM / SU
- `/despre` — Despre
- `/contact` — Contact + formular (mailto)

## Brand

Culori din guideline comunicare: `#D7B532`, `#A7DFFC`, `#FFDE59`, `#6E3A28`.
