"""Result validity must fail closed without misclassifying stock headless UI warnings."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location('benchmark', Path(__file__).resolve().parents[1]/'tools/benchmark.py')
b = importlib.util.module_from_spec(spec)
spec.loader.exec_module(b)

class Results(unittest.TestCase):
    def result(self, extra='', complete=True):
        with tempfile.TemporaryDirectory() as directory:
            target=Path(directory)
            lines=['[CL-BENCH-METRIC] {"team":1,"army":5,"time":200}', '[CL-BENCH-CLIENT] {"time":200}']
            if complete: lines.append('[CL-BENCH-RESULT] {"winners":[0],"time":200}')
            (target/'infolog.txt').write_text('\n'.join(lines)+extra)
            return b.summarize(target, {'side':0}, 30)['outcome']
    def test_win(self): self.assertEqual(self.result(), 'WIN')
    def test_cap(self): self.assertEqual(self.result(complete=False), 'CENSORED')
    def test_ai_init(self): self.assertEqual(self.result('\nError: error 201 handling EVENT_INIT'), 'INVALID')
    def test_driver_missing(self): self.assertEqual(self.result('\nFailed to load: gui_cl_benchmark_driver.lua'), 'INVALID')
    def test_stock_warning(self): self.assertEqual(self.result('\nFailed to load: gui_tech_k.lua (no GetInfo() call)'), 'WIN')
    def test_controller_runtime(self): self.assertEqual(self.result('\nError in Update(): Economy.lua'), 'INVALID')

if __name__=='__main__': unittest.main()
