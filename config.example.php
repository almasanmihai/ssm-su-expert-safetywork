<?php
/**
 * Config SMTP pentru formularul de contact.
 *
 * Copiază PE SERVER la:
 *   /home/USERUL_CPANEL/tcasafework-config/config.php
 *
 * - Folderul e lângă public_html, NU înăuntru.
 * - Nu se urcă pe git (vezi .gitignore).
 * - Înlocuiește PAROLA_EMAIL înainte de a salva.
 * - Pași compleți: DEPLOY.md (checklist formular).
 */
return [
	'smtp_host' => 'mail.tcasafework.ro',
	'smtp_port' => 465,
	// 'ssl' = port 465 SMTPS; 'tls' = port 587 STARTTLS
	'smtp_secure' => 'ssl',
	'smtp_user' => 'office@tcasafework.ro',
	'smtp_pass' => 'PAROLA_EMAIL',
	'mail_from' => 'office@tcasafework.ro',
	'mail_from_name' => 'TCA SAFEWORK',
	'mail_to' => 'office@tcasafework.ro',
];
