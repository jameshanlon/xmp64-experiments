XCC         := xcc
XCC_FLAGS   := -Wall -g -O2 
TARGET      := XK-XMP-64
PROGRAM     := ping.xe

COMPILE_XCC := $(XCC) $(XCC_FLAGS) -c
LINK_XCC    := $(XCC) $(XCC_FLAGS) -target=$(TARGET) #--show-report

SRCEXTS     := .c .xc .S .s

SRC_DIRS := \
    .

COMMON_SRCS := \
    ../common/hcube.xc \
    ../common/sync.xc \
    ../common/timing.S

SRCS := $(foreach d, $(SRC_DIRS), $(wildcard $(addprefix $(d)/*,$(SRCEXTS)))) \
    $(COMMON_SRCS)
OBJS := $(addsuffix .o, $(basename $(SRCS)))

all: $(PROGRAM)

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
	@echo 'Generating executable ...'
	$(LINK_XCC) $(OBJS) -o $(PROGRAM)  

.PHONY:
	dump clean show	

dump: $(TARGET).dump
$(PROGRAM).dump: $(PROGRAM)
	@echo 'Generating dump for executable...'
	xobjdump -d $(program) > $(program).dump
	@echo 'Dump complete'

clean:
	@rm $(OBJS) $(PROGRAM)

show:
	@echo 'TARGET      :' $(TARGET)
	@echo 'PROGRAM     :' $(PROGRAM)
	@echo 'SOURCES     :' $(SRCS)
	@echo 'OBJS        :' $(OBJS)
	@echo 'LIBS        :' $(LIBS)
	@echo 'COMPILE_XCC :' $(COMPILE_XCC)
	@echo 'LINK_XCC    :' $(LINK_XCC)
