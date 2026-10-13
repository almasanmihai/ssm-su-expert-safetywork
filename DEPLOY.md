# Deploy Hostico — tcasafework.ro

Site-ul se construiește pe GitHub (branch `hostico`) și se copiază pe cPanel. Nu rulați `npm` pe server.

Înlocuiți peste tot `USERCPANEL` cu userul cPanel (îl vedeți în colțul dreapta-sus din cPanel).

> Formularul de pe `astro dev` **nu trimite mail** (nu rulează PHP). Testul real e doar pe Hostico, după pașii 1–2.

## Checklist rapid — formular `office@tcasafework.ro`

Fără acești pași, `contact.php` răspunde: *„Formularul nu este configurat pe server”*.

- [ ] Căsuța `office@tcasafework.ro` creată în cPanel → Email Accounts
- [ ] Parola mailului salvată undeva sigur
- [ ] Folder `/home/USERCPANEL/tcasafework-config/` creat **lângă** `public_html` (nu înăuntru)
- [ ] Fișier `config.php` acolo, pe baza `config.example.php`, cu `smtp_pass` real
- [ ] Site deployat pe `public_html` (branch `hostico`)
- [ ] Test pe https://tcasafework.ro/contact/ — mail în inbox + Reply-To = emailul vizitatorului

## 1. Cont de email

1. cPanel → **Email Accounts** → Create.
2. Adresă: `office@tcasafework.ro`, parolă puternică, salvați-o.
3. SPF și DKIM rămân cele activate automat de Hostico.

## 2. Fișierul `config.php` (în afara site-ului)

1. cPanel → **File Manager**.
2. În `/home/USERCPANEL/` creați folderul `tcasafework-config` (lângă `public_html`, nu înăuntru).
3. Creați `config.php` acolo, cu conținutul din `config.example.php` din repo.
4. Puneți parola reală la `smtp_pass`.
5. Dacă trimiterea eșuează, schimbați în config: `smtp_host` / `smtp_port` / `smtp_secure` (ex. port `587` și `'tls'`).

Cale finală: `/home/USERCPANEL/tcasafework-config/config.php`

Valori implicite din exemplu:

| Cheie | Valoare |
|---|---|
| `smtp_host` | `mail.tcasafework.ro` |
| `smtp_port` | `465` (`ssl`) sau `587` (`tls`) |
| `smtp_user` / `mail_from` / `mail_to` | `office@tcasafework.ro` |

## 3. Git Version Control

1. Așteptați ca GitHub Action **Build Hostico** să termine după push pe `main` (tab Actions). Se creează branch-ul `hostico` cu HTML-ul gata.
2. cPanel → **Git Version Control** → Create.
3. Clone URL: repo-ul public GitHub.
4. Branch: **`hostico`** (nu `main` — `main` are sursa Astro, nu site-ul compilat).
5. Repository Path: lăsați calea implicită (ex. `/home/USERCPANEL/repositories/...`).
6. În `.cpanel.yml` din acest repo, înlocuiți `USERCPANEL` cu userul cPanel, faceți commit + push, apoi așteptați din nou Action-ul. Nu lăsați placeholder-ul: la următorul Update from Remote s-ar suprascrie o editare făcută doar în cPanel.
7. **Update from Remote**, apoi **Deploy HEAD Commit**.

`.cpanel.yml` copiază doar fișierele publice în `/home/USERCPANEL/public_html/` (inclusiv `contact.php` și `phpmailer/`).

## 4. SSL

cPanel → **SSL/TLS Status** (sau Let's Encrypt) → activați certificatul pentru `tcasafework.ro` și `www.tcasafework.ro`.

## 5. Test formular

1. Deschideți https://tcasafework.ro/contact/
2. Trimiteți o solicitare reală (bifați GDPR). Așteptați cel puțin ~3 secunde pe pagină înainte de trimitere (anti-spam).
3. Verificați că ajunge la `office@tcasafework.ro` și că Reply-To este emailul vizitatorului.
4. Reîncărcați pagina, dezactivați JavaScript în browser și trimiteți din nou — trebuie să apară pagina de confirmare.

### Dacă trimiterea eșuează

1. Verificați că `config.php` e citibil la calea de mai sus (nu în `public_html`).
2. Încercați `smtp_port` `587` + `smtp_secure` `'tls'`.
3. Verificați parola mailului în cPanel → Email Accounts.
4. Confirmați că `contact.php` și folderul `phpmailer/` există în `public_html` după Deploy.

## Actualizări ulterioare

După fiecare `git push` pe `main`: așteptați Action-ul, apoi în cPanel **Update from Remote** + **Deploy HEAD Commit**.
