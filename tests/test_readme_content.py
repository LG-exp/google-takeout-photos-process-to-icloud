import unittest

class TestReadmeContent(unittest.TestCase):
    def test_readme_has_expected_heading(self):
        with open('readme.md', encoding='utf-8') as f:
            content = f.read()
        self.assertIn('Migrating from Google Photos to iCloud', content)

if __name__ == '__main__':
    unittest.main()
