TARGET      := XK-XMP-64
XCC         := xcc
XCC_FLAGS   := -Wall -g -O0 -target=$(TARGET)
LIBS        :=
PROGRAM     := traffic.xe

COMPILE_XCC := $(XCC) $(XCC_FLAGS) -c
LINK_XCC    := $(XCC) $(XCC_FLAGS) #--show-report

SRCEXTS     := .c .xc .S .s

JC          := javac
JC_FLAGS    := -g

WRAPPER_SRCS := \
    wrapper/Main.java \
    wrapper/Results.java \
    wrapper/Series.java \
    wrapper/Utilities.java

SRC_DIRS := \
    ../common \
    .

SRCS := $(foreach d, $(SRC_DIRS), $(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
OBJS := $(addsuffix .o, $(basename $(SRCS)))

.PHNOY:
	dump clean show	

all: wrapper

# Rules for generating Java wrapper program
WRAPPER_CLASSES := $(WRAPPER_SRCS:.java=.class)

wrapper: $(WRAPPER_CLASSES)

traffic: traffic.xe

%.class: %.java
	@echo 'Generating wrapper program...'
	@$(JC) $(JFLAGS) $<

# Rules for generating XC traffic program
#traffic: $(PROGRAM)

# Rules for generating object files (.o).
%.o:%.c
	$(COMPILE_XCC) $< -o $@
            
%.o:%.xc
	$(COMPILE_XCC) $< -o $@

%.o:%.S
	$(COMPILE_XCC) $< -o $@

%.o:%.s
	$(COMPILE_XCC) $< -o $@

# Rules for generating the executables.
$(PROGRAM): $(OBJS)
	@echo 'Generating executable...'
	$(LINK_XCC) $(OBJS) $(LIBS) -o $@
                    
dump: $(TARGET).dump
$(PROGRAM).dump: $(PROGRAM)
	@echo 'Generating dump for executable...'
	xobjdump -d $(program) > $(program).dump
	@echo 'Dump complete'

clean:
	@rm $(OBJS) $(PROGRAM) wrapper/*.class

show:
	@echo 'TARGET      :' $(TARGET)
	@echo 'PROGRAM     :' $(PROGRAM)
	@echo 'SOURCES     :' $(SRCS)
	@echo 'OBJS        :' $(OBJS)
	@echo 'LIBS        :' $(LIBS)
	@echo 'COMPILE_XCC :' $(COMPILE_XCC)
	@echo 'LINK_XCC    :' $(LINK_XCC)
