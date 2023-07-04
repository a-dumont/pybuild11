<pre>
                                       ___________________________________________    
                                      |              _           _ _     _   _ _  |   
                                      |  _ __  _   _| |__  _   _(_) | __| | / / | |   
                                      | |  _ \| | | |  _ \| | | | | |/ _  | | | | |   
                                      | | |_) | |_| | |_) | |_| | | | (_| | | | | |   
                                      | | .__/ \__, |_.__/ \__,_|_|_|\__,_| |_|_| |   
                                      | |_|    |___/                              |   
                                      |___________________________________________|   
</pre>

This shell script is intended to create the directory structure and relevant files for a python module using pybind11. 

For a module named **HelloWorld** with no submodules the script would create the following:
```bash
HelloWorld/
├── build
├── includes
├── obj
│   └── libhelloworld
├── src
│   ├── HelloWorld.cpp
│   ├── HelloWorld.h
│   ├── HelloWorld_py.cpp
│   ├── HelloWorld_py.h
│   ├── HelloWorld_py.tpp
│   └── HelloWorld.tpp
├── CMakeLists.txt
├── MANIFEST.in
├── setup.py
├── README.md
├── HelloWorld
    ├── __init__.py
    └── libhelloworld
```

Where ```src``` contains sample c++ code and the inner ```HelloWorld``` directory is the python module.   

The script automatically compiles the sample c++ code copies and copies the library to the python module.   
To test the module launch a python interpreter in the outermost ```HelloWorld``` directory and run:

```python
import HelloWorld
HelloWorld.hello_world()
```

If everything works fine the sample c++ code can be overwitten by useful code.

To recompile after changes make sure to update the ```CMakeLists.txt``` file with any required flags or links and from the ```build``` directory run:

```bash
cmake .. && cmake --build . && cmake --install .
```

Note that for cross compiling using cygwin and MinGW the command is:

```bash
CXX=/usr/bin/x86_64-w64-mingw32-g++.exe cmake .. && cmake --build . && cmake --install .
```

Finally the module can be installed using:

```bash
python setup.py install
```
