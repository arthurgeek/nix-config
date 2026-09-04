type ExtensionAPI = {
	on(event: "session_start", handler: (event: unknown, context: SessionContext) => void): void;
};

type SessionContext = {
	ui: {
		setStatus(name: string, value: string): void;
		theme: { fg(color: string, value: string): string };
	};
};

export default function profileStatus(pi: ExtensionAPI): void {
	pi.on("session_start", (_event, context) => {
		const profile = process.env.PI_PROFILE || "pi";
		context.ui.setStatus("profile", context.ui.theme.fg("muted", `profile: ${profile}`));
	});
}
