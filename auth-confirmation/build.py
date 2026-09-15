from pathlib import Path
import shutil
Path('dist').mkdir(exist_ok=True)
shutil.copyfile('index.html', 'dist/index.html')
