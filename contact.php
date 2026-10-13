<?php
declare(strict_types=1);

use PHPMailer\PHPMailer\Exception;
use PHPMailer\PHPMailer\PHPMailer;

header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: strict-origin-when-cross-origin');
header('Cache-Control: no-store, no-cache, must-revalidate');

const LIMITS = [
	'nume' => 120,
	'telefon' => 40,
	'email' => 120,
	'domeniu' => 200,
	'angajati' => 10,
	'locatie' => 120,
	'mesaj' => 2000,
];

const MIN_SECONDS = 3;
const MAX_SECONDS = 21600;

function wants_json(): bool
{
	$accept = $_SERVER['HTTP_ACCEPT'] ?? '';
	if (stripos($accept, 'application/json') !== false) {
		return true;
	}
	$xhr = $_SERVER['HTTP_X_REQUESTED_WITH'] ?? '';
	return strcasecmp($xhr, 'XMLHttpRequest') === 0;
}

function respond(bool $ok, string $message, int $status = 200): void
{
	http_response_code($status);
	if (wants_json()) {
		header('Content-Type: application/json; charset=utf-8');
		echo json_encode(['ok' => $ok, 'message' => $message], JSON_UNESCAPED_UNICODE);
		exit;
	}

	$title = $ok ? 'Mesaj trimis' : 'Mesajul nu a fost trimis';
	$tone = $ok ? '#3d342f' : '#6e3a28';
	$safe = htmlspecialchars($message, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
	header('Content-Type: text/html; charset=utf-8');
	echo '<!doctype html><html lang="ro"><head><meta charset="utf-8">';
	echo '<meta name="viewport" content="width=device-width, initial-scale=1">';
	echo '<meta name="robots" content="noindex, nofollow">';
	echo '<title>' . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . ' | TCA SAFEWORK</title>';
	echo '<style>body{font-family:Manrope,system-ui,sans-serif;background:#f7f5f2;color:#1a1614;margin:0;padding:2.5rem 1.25rem;line-height:1.6}main{max-width:36rem;margin:0 auto;background:#fff;padding:2rem;border:1px solid rgba(110,58,40,.12)}h1{font-family:Syne,system-ui,sans-serif;font-size:1.6rem;margin:0 0 1rem}p{color:' . $tone . '}a{color:#6e3a28;font-weight:700}</style></head><body><main>';
	echo '<h1>' . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . '</h1>';
	echo '<p>' . $safe . '</p>';
	echo '<p><a href="/contact/#formular">Înapoi la formular</a></p>';
	echo '</main></body></html>';
	exit;
}

function field(string $key): string
{
	$value = $_POST[$key] ?? '';
	if (!is_string($value)) {
		return '';
	}
	return trim(str_replace("\0", '', $value));
}

	if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
	respond(false, 'Formularul se trimite prin POST. Folosește pagina de contact.', 405);
}

$honeypot = field('website');
$formTs = field('form_ts');
$nume = field('nume');
$telefon = field('telefon');
$email = field('email');
$domeniu = field('domeniu');
$angajati = field('angajati');
$locatie = field('locatie');
$mesaj = field('mesaj');
$gdpr = field('gdpr');

if ($honeypot !== '') {
	respond(true, 'Mesajul a fost trimis. Te contactăm în maximum 24 de ore.');
}

if ($formTs !== '') {
	if (!ctype_digit($formTs)) {
		respond(false, 'Solicitarea nu a putut fi validată. Reîncarcă pagina și încearcă din nou.', 400);
	}
	$elapsed = time() - (int) $formTs;
	if ($elapsed < MIN_SECONDS || $elapsed > MAX_SECONDS) {
		respond(false, 'Solicitarea nu a putut fi validată. Reîncarcă pagina și încearcă din nou.', 400);
	}
}

$errors = [];
if ($nume === '') {
	$errors[] = 'Numele este obligatoriu.';
}
if ($telefon === '') {
	$errors[] = 'Telefonul este obligatoriu.';
}
if ($email === '' || filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
	$errors[] = 'Adresa de email nu este validă.';
}
if ($domeniu === '') {
	$errors[] = 'Domeniul de activitate este obligatoriu.';
}
if ($angajati === '' || !preg_match('/^[0-9]+$/', $angajati) || (int) $angajati < 1) {
	$errors[] = 'Numărul de angajați trebuie să fie un număr pozitiv.';
}
if ($locatie === '') {
	$errors[] = 'Locația este obligatorie.';
}
if ($gdpr !== '1') {
	$errors[] = 'Trebuie să fii de acord cu prelucrarea datelor personale.';
}

foreach (LIMITS as $key => $max) {
	$current = field($key);
	if (function_exists('mb_strlen')) {
		$length = mb_strlen($current, 'UTF-8');
	} else {
		$length = strlen($current);
	}
	if ($length > $max) {
		$errors[] = 'Unul dintre câmpuri depășește lungimea maximă permisă.';
		break;
	}
}

if ($errors) {
	respond(false, implode(' ', array_unique($errors)), 400);
}

$configFile = dirname(__DIR__) . '/tcasafework-config/config.php';
if (!is_readable($configFile)) {
	respond(false, 'Formularul nu este configurat pe server. Sună-ne la 0762 682 850.', 500);
}

$config = require $configFile;
if (!is_array($config)) {
	respond(false, 'Configurația de e-mail este invalidă. Sună-ne la 0762 682 850.', 500);
}

$requiredKeys = ['smtp_host', 'smtp_port', 'smtp_secure', 'smtp_user', 'smtp_pass', 'mail_from', 'mail_from_name', 'mail_to'];
foreach ($requiredKeys as $key) {
	if (!isset($config[$key]) || $config[$key] === '') {
		respond(false, 'Configurația de e-mail este incompletă. Sună-ne la 0762 682 850.', 500);
	}
}

require __DIR__ . '/phpmailer/Exception.php';
require __DIR__ . '/phpmailer/PHPMailer.php';
require __DIR__ . '/phpmailer/SMTP.php';

$plain = implode("\n", [
	'Mesaj nou de pe tcasafework.ro',
	'',
	'Nume: ' . $nume,
	'Telefon: ' . $telefon,
	'Email: ' . $email,
	'Domeniu de activitate: ' . $domeniu,
	'Număr de angajați: ' . $angajati,
	'Locația: ' . $locatie,
	'',
	'Mesaj:',
	$mesaj !== '' ? $mesaj : '(fără mesaj)',
	'',
	'Acord GDPR: da',
]);

$html = '<p><strong>Mesaj nou de pe tcasafework.ro</strong></p><table>';
$rows = [
	'Nume' => $nume,
	'Telefon' => $telefon,
	'Email' => $email,
	'Domeniu de activitate' => $domeniu,
	'Număr de angajați' => $angajati,
	'Locația' => $locatie,
];
foreach ($rows as $label => $value) {
	$html .= '<tr><td>' . htmlspecialchars($label, ENT_QUOTES, 'UTF-8') . '</td><td>'
		. htmlspecialchars($value, ENT_QUOTES, 'UTF-8') . '</td></tr>';
}
$html .= '</table><p><strong>Mesaj</strong><br>'
	. nl2br(htmlspecialchars($mesaj !== '' ? $mesaj : '(fără mesaj)', ENT_QUOTES, 'UTF-8'))
	. '</p><p>Acord GDPR: da</p>';

try {
	$mail = new PHPMailer(true);
	$mail->CharSet = 'UTF-8';
	$mail->isSMTP();
	$mail->Host = (string) $config['smtp_host'];
	$mail->Port = (int) $config['smtp_port'];
	$mail->SMTPAuth = true;
	$mail->Username = (string) $config['smtp_user'];
	$mail->Password = (string) $config['smtp_pass'];
	$secure = strtolower((string) $config['smtp_secure']);
	$mail->SMTPSecure = $secure === 'tls' ? PHPMailer::ENCRYPTION_STARTTLS : PHPMailer::ENCRYPTION_SMTPS;
	$mail->setFrom((string) $config['mail_from'], (string) $config['mail_from_name']);
	$mail->addAddress((string) $config['mail_to']);
	$mail->addReplyTo($email, $nume);
	$mail->Subject = 'Mesaj nou de pe tcasafework.ro – ' . $nume;
	$mail->isHTML(true);
	$mail->Body = $html;
	$mail->AltBody = $plain;
	$mail->send();
} catch (Exception $e) {
	respond(false, 'Mesajul nu a putut fi trimis acum. Încearcă din nou sau sună la 0762 682 850.', 500);
}

respond(true, 'Mesajul a fost trimis. Te contactăm în maximum 24 de ore.');
