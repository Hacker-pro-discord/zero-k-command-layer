from pathlib import Path
from lupa.lua51 import LuaRuntime
root=Path(__file__).resolve().parents[1]
lua=LuaRuntime(unpack_returned_tuples=True)
for f in (root/'LuaUI').rglob('*.lua'):
    result=lua.eval('loadstring')(f.read_text(encoding='utf-8'),str(f))
    assert not isinstance(result,tuple),result
print('PASS: Lua 5.1 syntax for all modules')
for f in sorted((root/'tests').glob('test_*.lua')):
    runtime=LuaRuntime(unpack_returned_tuples=True)
    runtime.globals().ROOT=root.as_posix()
    runtime.execute(f.read_text(encoding='utf-8'))
    print('PASS:',f.name)
