import pathlib
import unittest

class TestScriptsExist(unittest.TestCase):
    def test_scripts_exist(self):
        required_files = [
            '1-correctDatesParallelA.ps1',
            '1-correctDatesParallelB.ps1',
            '2-moveAlready.ps1',
            '3-changeCodedMP4s.ps1',
            '2-filesToMove.txt',
            'readme.md'
        ]
        for file in required_files:
            with self.subTest(file=file):
                self.assertTrue(pathlib.Path(file).exists(), f"{file} should exist")

if __name__ == '__main__':
    unittest.main()
