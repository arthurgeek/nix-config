type ToolCallEvent = {
	toolName: string;
	input: Record<string, unknown>;
};

type ExtensionAPI = {
	on(event: "tool_call", handler: (event: ToolCallEvent) => { block: true; reason: string } | undefined): void;
};

const PROJECT_ONLY_REASON = "Hermes writes are restricted to project memory.";

export default function hermesProjectPolicy(pi: ExtensionAPI): void {
	pi.on("tool_call", (event) => {
		if (event.toolName.startsWith("memory_") && event.toolName !== "memory_search") {
			if (event.input.target !== "project") return { block: true, reason: PROJECT_ONLY_REASON };
		}

		if (event.toolName === "skill_manage" && event.input.action !== "view") {
			const projectWrite =
				event.input.scope === "project" ||
				(typeof event.input.skill_id === "string" && event.input.skill_id.startsWith("project:"));
			if (!projectWrite) return { block: true, reason: PROJECT_ONLY_REASON };
		}
	});
}
