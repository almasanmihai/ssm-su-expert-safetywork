export const company = {
	brand: "TCA SAFEWORK",
	legalName: "TCA SAFEWORK S.R.L.",
	cui: "53272588",
	tradeRegister: "J2026002183008",
	street: "Str. Căpitan Ivan Anghelache nr. 3",
	sector: "Sector 5",
	city: "București",
	email: "office@tcasafework.ro",
	phones: ["0762 682 850", "0763 693 715"] as const,
};

export const companyAddress = `${company.street}, ${company.sector}, ${company.city}`;
