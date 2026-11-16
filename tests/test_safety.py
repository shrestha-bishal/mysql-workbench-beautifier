import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BEAUTIFIER = (ROOT / "src" / "beautifier.ahk").read_text(encoding="utf-8")
BINDINGS = (ROOT / "src" / "key_bindings.ahk").read_text(encoding="utf-8")


class BeautifierSafetyTests(unittest.TestCase):
    def test_keyword_list_is_normalized_and_unique(self):
        keywords = [
            line.strip().lower()
            for line in (ROOT / "config" / "keywords.txt").read_text(
                encoding="utf-8"
            ).splitlines()
            if line.strip()
        ]
        self.assertTrue(keywords)
        self.assertEqual(len(keywords), len(set(keywords)))
        self.assertTrue(all(re.fullmatch(r"[a-z_][a-z0-9_]*", word) for word in keywords))
        self.assertTrue({"select", "json_table", "row_number", "date_format", "bigint"} <= set(keywords))

    def test_replacement_never_uses_word_selection_shortcuts(self):
        self.assertNotIn("^+{Left}", BEAUTIFIER)
        self.assertIn("Loop, % StrLen(word)", BEAUTIFIER)
        self.assertIn("SendInput, {Backspace}", BEAUTIFIER)
        self.assertIn("keywords.HasKey(word)", BEAUTIFIER)

    def test_tracking_fails_closed_for_modifiers_and_long_tokens(self):
        self.assertIn('GetKeyState("Ctrl", "P")', BEAUTIFIER)
        self.assertIn('GetKeyState("Alt", "P")', BEAUTIFIER)
        self.assertIn('RegExMatch(char, "^[0-9]$")', BEAUTIFIER)
        self.assertIn("StrLen(word) > 64", BEAUTIFIER)
        self.assertIn("InvalidateWord()", BEAUTIFIER)

    def test_quoted_text_is_not_formatted_before_newline(self):
        self.assertIn("unsafeUntilNewline := true", BEAUTIFIER)
        self.assertIn('if (delimiter = "`n")', BEAUTIFIER)
        self.assertIn("unsafeUntilNewline := false", BEAUTIFIER)
        self.assertIn('HandleQuotedDelimiter("\'")', BINDINGS)
        self.assertIn("HandleQuotedDelimiter(Chr(34))", BINDINGS)
        self.assertIn('HandleQuotedDelimiter("``")', BINDINGS)
        self.assertIn('HandleUnsafeDelimiter("@")', BINDINGS)
        self.assertIn('HandleUnsafeDelimiter("$")', BINDINGS)

    def test_bindings_are_workbench_scoped_and_pauseable(self):
        self.assertIn("#IfWinActive ahk_exe MySQLWorkbench.exe", BINDINGS)
        self.assertIn("^!F8::ToggleBeautifier()", BINDINGS)
        self.assertIn("~*LButton::InvalidateWord()", BINDINGS)
        self.assertIn("~*MButton::InvalidateWord()", BINDINGS)
        self.assertIn("~*Left::InvalidateWord()", BINDINGS)
        self.assertIn("~+Space::InvalidateWord()", BINDINGS)
        self.assertIn("SetTimer, ResetWhenInactive, 20", (ROOT / "app.ahk").read_text())

    def test_common_token_boundaries_and_identifier_characters_are_covered(self):
        for binding in (
            'Space::HandleDelimiter(" ")',
            'Enter::HandleDelimiter("`n")',
            'Tab::HandleDelimiter("`t")',
            'SC033::HandleDelimiter(",")',
            'SC034::HandleDelimiter(".")',
            'SC027::HandleDelimiter(";")',
            '~+SC00C::AppendKey("_")',
            '~SC002::AppendKey("1")',
            '+SC00A::HandleDelimiter("(")',
            '+SC00B::HandleDelimiter(")")',
            'SC00C::HandleCommentCharacter("-")',
            'SC035::HandleCommentCharacter("/")',
            '~*Numpad1::AppendKey("1")',
            'NumpadEnter::HandleDelimiter("`n")',
            '~+Enter::InvalidateWord()',
        ):
            with self.subTest(binding=binding):
                self.assertIn(binding, BINDINGS)

    def test_line_and_block_comments_are_not_formatted(self):
        self.assertIn('char = "#" || (char = "-" && previousDelimiter = "-")', BEAUTIFIER)
        self.assertIn('char = "*" && previousDelimiter = "/"', BEAUTIFIER)
        self.assertIn('previousDelimiter = "*" && char = "/"', BEAUTIFIER)
        self.assertIn("inBlockComment := true", BEAUTIFIER)
        self.assertIn("inBlockComment := false", BEAUTIFIER)


if __name__ == "__main__":
    unittest.main()
