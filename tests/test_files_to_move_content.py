import unittest

class TestFilesToMoveContent(unittest.TestCase):
    def test_non_empty(self):
        with open('2-filesToMove.txt', 'r', encoding='utf-8') as f:
            lines = [line.strip() for line in f if line.strip()]
        self.assertGreater(len(lines), 0, '2-filesToMove.txt should contain at least one filename')

if __name__ == '__main__':
    unittest.main()
