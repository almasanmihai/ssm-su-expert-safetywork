# SSM & SU Expert SafetyWork — site de prezentare

Site static (Astro) pentru prezentarea serviciilor SSM / SU.

## Preview live (share cu echipa)

**https://almasanmihai.github.io/ssm-su-expert-safetywork/**

Repo: https://github.com/almasanmihai/ssm-su-expert-safetywork

## Local

```sh
npm install
npm run dev
```

Deschide `http://localhost:4321/ssm-su-expert-safetywork/`.

> Pe Windows, folderul local conține `&` în nume — de aceea scripturile apelează Astro prin `node ./node_modules/astro/bin/astro.mjs`.

## Build & deploy preview

```sh
npm run build
npm run deploy
```

`npm run deploy` publică folderul `dist` pe branch-ul `gh-pages` (GitHub Pages), inclusiv fișierele dot (`.nojekyll`) necesare ca assets din `_astro` să fie servite.

Opțional: există și `.github/workflows/deploy.yml` pentru deploy automat pe push. Pentru a-l activa pe remote, tokenul GitHub trebuie să aibă scope-ul `workflow` (`gh auth refresh -s workflow`), apoi:

```sh
git add .github/workflows/deploy.yml
git commit -m "Enable GitHub Actions Pages deploy"
git push
```

În Settings → Pages, sursa poate rămâne branch `gh-pages` sau trece pe GitHub Actions.

## Structură

- `/` — Acasă
- `/servicii` — Servicii SSM / SU
- `/despre` — Despre
- `/contact` — Contact + formular (mailto)

## Brand

Culori din guideline comunicare: `#D7B532`, `#A7DFFC`, `#FFDE59`, `#6E3A28`.
