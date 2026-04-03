import argparse
import sys
from typing import List, Dict

from openai import OpenAI
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Local Gemma chat client")
    parser.add_argument(
        "--model",
        default="gemma4:26b",
        help="Model name exposed by the OpenAI-compatible server.",
    )
    parser.add_argument(
        "--base-url",
        default="http://localhost:11434/v1",
        help="OpenAI-compatible API base URL.",
    )
    parser.add_argument(
        "--system",
        default="You are a helpful assistant.",
        help="Initial system prompt.",
    )
    return parser


def run_chat(model: str, base_url: str, system_prompt: str) -> int:
    console = Console()
    client = OpenAI(base_url=base_url, api_key="not-needed")
    history: List[Dict[str, str]] = [{"role": "system", "content": system_prompt}]

    console.print(
        Panel.fit(
            "Gemma local chat\n"
            "Commands: /exit, /clear, /model <name>, /system <prompt>",
            title="Ready",
        )
    )

    while True:
        try:
            user_text = console.input("[bold cyan]you> [/bold cyan]").strip()
        except (KeyboardInterrupt, EOFError):
            console.print("\nExiting.")
            return 0

        if not user_text:
            continue

        if user_text.startswith("/"):
            if user_text == "/exit":
                return 0
            if user_text == "/clear":
                history = [{"role": "system", "content": system_prompt}]
                console.print("[yellow]Conversation history cleared.[/yellow]")
                continue
            if user_text.startswith("/model "):
                model = user_text.split(" ", 1)[1].strip()
                console.print(f"[green]Model set to:[/green] {model}")
                continue
            if user_text.startswith("/system "):
                system_prompt = user_text.split(" ", 1)[1].strip()
                history[0] = {"role": "system", "content": system_prompt}
                console.print("[green]System prompt updated.[/green]")
                continue
            console.print("[red]Unknown command.[/red]")
            continue

        history.append({"role": "user", "content": user_text})
        console.print("[bold magenta]assistant>[/bold magenta] ", end="")

        assistant_text = ""
        try:
            stream = client.chat.completions.create(
                model=model,
                messages=history,
                stream=True,
            )
            for chunk in stream:
                delta = chunk.choices[0].delta.content or ""
                if delta:
                    assistant_text += delta
                    console.print(delta, end="")
            console.print()
        except Exception as exc:  # noqa: BLE001
            console.print(f"\n[red]Request failed:[/red] {exc}")
            history.pop()  # Drop the user turn on failure.
            continue

        history.append({"role": "assistant", "content": assistant_text})
        if assistant_text.strip():
            console.print(Markdown(assistant_text))


def main() -> int:
    args = build_parser().parse_args()
    return run_chat(model=args.model, base_url=args.base_url, system_prompt=args.system)


if __name__ == "__main__":
    sys.exit(main())
