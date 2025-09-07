### Build Options ###

BASEEXE      := PSX.EXE
TARGET       := psx.exe
COMPARE      ?= 1
NON_MATCHING ?= 0
SKIP_ASM     ?= 0
VERBOSE      ?= 0
BUILD_DIR    ?= build
TOOLS_DIR    := tools
OBJDIFF_DIR  := $(TOOLS_DIR)/objdiff
EXPECTED_DIR ?= expected
CHECK        ?= 1

# Fail early if baserom does not exist
ifeq ($(wildcard $(BASEEXE)),)
$(error Baserom `$(BASEEXE)' not found.)
endif

# NON_MATCHING=1 implies COMPARE=0
ifeq ($(NON_MATCHING),1)
override COMPARE=0
endif

ifeq ($(VERBOSE),0)
V := @
endif

ifeq ($(OS),Windows_NT)
  DETECTED_OS=windows
else
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S),Linux)
    DETECTED_OS=linux
  endif
  ifeq ($(UNAME_S),Darwin)
    DETECTED_OS=macos
    MAKE=gmake
    CPPFLAGS += -xc++
  endif
endif

### Output ###

EXE          := $(BUILD_DIR)/$(TARGET).EXE
ELF          := $(BUILD_DIR)/$(TARGET).elf
LD_SCRIPT    := $(TARGET).ld
LD_MAP       := $(BUILD_DIR)/$(TARGET).map

### Tools ###

PYTHON     := python3
SPLAT_YAML := $(BASEEXE).yaml
SPLAT      := $(PYTHON) -m splat split $(SPLAT_YAML)
DIFF       := diff
MASPSX     := $(PYTHON) tools/maspsx/maspsx.py --use-comm-section --aspsx-version=2.81 -G4096
CROSS    := mips-linux-gnu-
AS       := $(CROSS)as -EL
LD       := $(CROSS)ld -EL
OBJCOPY  := $(CROSS)objcopy
STRIP    := $(CROSS)strip
CPP      := $(CROSS)cpp
CC       := tools/gcc-2.6.3-psx/cc1
CC_HOST  := gcc
OBJDIFF  := $(OBJDIFF_DIR)/objdiff

PRINT := printf '
 ENDCOLOR := \033[0m
 WHITE     := \033[0m
 ENDWHITE  := $(ENDCOLOR)
 GREEN     := \033[0;32m
 ENDGREEN  := $(ENDCOLOR)
 BLUE      := \033[0;34m
 ENDBLUE   := $(ENDCOLOR)
 YELLOW    := \033[0;33m
 ENDYELLOW := $(ENDCOLOR)
 PURPLE    := \033[0;35m
 ENDPURPLE := $(ENDCOLOR)
ENDLINE := \n'

### Compiler Options ###

ASFLAGS        := -Iinclude -march=r3000 -mtune=r3000 -no-pad-sections
CFLAGS         := -O3 -G4096 -gcoff -quiet -fsigned-char
CPPFLAGS       := -Iinclude -Isrc -DTARGET_PSX
LDFLAGS        := -T undefined_syms.txt -T undefined_funcs.txt -T $(BUILD_DIR)/$(LD_SCRIPT) -Map $(LD_MAP) \
                  --no-check-sections -nostdlib
CFLAGS_CHECK   := -fsyntax-only -fno-builtin -std=gnu90
CHECK_WARNINGS := -Wall -Wextra

ifeq ($(NON_MATCHING),1)
CPPFLAGS += -DNON_MATCHING
endif

ifeq ($(SKIP_ASM),1)
CPPFLAGS := $(CPPFLAGS) -DSKIP_ASM
endif

### Sources ###

ASM_SRCS := $(shell find asm/ -type f -name '*.s')
ASM_OBJS := $(ASM_SRCS:asm/%.s=$(BUILD_DIR)/asm/%.o)

C_SRCS := $(shell find src/ -name '*.c')
C_OBJS := $(C_SRCS:%.c=$(BUILD_DIR)/%.o)

# Object files
OBJECTS := $(shell grep -E 'BUILD_PATH.+\.o' $(LD_SCRIPT) -o)
OBJECTS := $(OBJECTS:BUILD_PATH/%=$(BUILD_DIR)/%)
ifeq ($(SKIP_ASM),1)
OBJECTS += $(ASM_OBJS)
endif
DEPENDS := $(OBJECTS:=.d)

### Targets ###

# $(BUILD_DIR)/src/Game/CINEMA/CINEPSX.c.o: CFLAGS += -G0

# $(BUILD_DIR)/src/Game/MCARD/MEMCARD.c.o: CFLAGS += -G0
# $(BUILD_DIR)/src/Game/MCARD/MCASSERT.c.o: CFLAGS += -G0

# $(BUILD_DIR)/src/Game/MENU/MENUUTIL.c.o: CFLAGS += -G0

# $(BUILD_DIR)/src/Game/G2/QUATG2.c.o: CFLAGS += -funsigned-char

# $(BUILD_DIR)/src/Game/PLAN/ENMYPLAN.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PLAN/PLANPOOL.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PLAN/PLANAPI.c.o: CFLAGS += -funsigned-char

# $(BUILD_DIR)/src/Game/PSX/AADLIB.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PSX/AADSEQEV.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PSX/AADSFX.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PSX/AADSQCMD.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PSX/AADVOICE.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PSX/MAIN.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/PSX/SUPPORT.c.o: CFLAGS += -funsigned-char

# $(BUILD_DIR)/src/Game/DRAW.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/STRMLOAD.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/INSTANCE.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/DEBUG.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/SOUND.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/MEMPACK.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/LOAD3D.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/FONT.c.o: CFLAGS += -funsigned-char
# $(BUILD_DIR)/src/Game/EVENT.c.o: CFLAGS += -funsigned-char

# $(BUILD_DIR)/src/Game/MONSTER/MONMSG.c.o: CFLAGS += -funsigned-char

# $(BUILD_DIR)/src/Game/MENU/MENUFACE.c.o: CFLAGS += -funsigned-char

# $(BUILD_DIR)/src/Game/RAZIEL/RAZIEL.c.o: CFLAGS += -funsigned-char

ifeq ($(SKIP_ASM),1)
all: $(OBJECTS)
	@echo "SKIP_ASM=1: Skipping linking, only built objects."
else
all: $(EXE)
endif

-include $(DEPENDS)

clean:
	$(V)rm -rf $(BUILD_DIR)
	$(V)rm -rf $(EXPECTED_DIR)

distclean: clean
	$(V)rm -f $(LD_SCRIPT)
	$(V)rm -rf asm
	$(V)rm -rf *_auto.txt

setup: distclean split

split:
	$(V)$(SPLAT)

reset: clean
	$(V)rm -rf $(EXPECTED_DIR)

regenerate: reset

objdiff-config: regenerate
	@$(MAKE) NON_MATCHING=1 SKIP_ASM=1 expected -j12
	@$(PYTHON) $(OBJDIFF_DIR)/objdiff_generate.py $(OBJDIFF_DIR)/config.yaml

report: objdiff-config
	@$(OBJDIFF) report generate > $(BUILD_DIR)/progress.json

progress:
	$(MAKE) build NON_MATCHING=1 SKIP_ASM=1

expected: all
	@mkdir -p $(EXPECTED_DIR)
	$(V)mv $(BUILD_DIR)/asm $(EXPECTED_DIR)/asm
	$(V)mv $(BUILD_DIR)/src $(EXPECTED_DIR)/src
	$(V)find $(EXPECTED_DIR)/src -name '*.s.o' -delete

# Compile .c files
$(BUILD_DIR)/%.o: %.c
	@$(PRINT)$(GREEN)Compiling C file: $(ENDGREEN)$(BLUE)$<$(ENDBLUE)$(ENDLINE)
	@mkdir -p $(shell dirname $@)
ifeq ($(CHECK),1)
	@$(CC_HOST) $(CFLAGS_CHECK) $(CHECK_WARNINGS) $(CPPFLAGS) -UTARGET_PSX $<
endif
	$(V)$(CPP) $(CPPFLAGS) -ffreestanding -MMD -MP -MT $@ -MF $@.d $< | $(CC) $(CFLAGS) | $(MASPSX) | $(AS) $(ASFLAGS) -o $@
OBJECTS += $(C_OBJS)
# Compile .s files
$(BUILD_DIR)/asm/%.o: asm/%.s
	@$(PRINT)$(GREEN)Assembling asm file: $(ENDGREEN)$(BLUE)$<$(ENDBLUE)$(ENDLINE)
	@mkdir -p $(shell dirname $@)
	$(V)$(AS) $(ASFLAGS) -o $@ $<
OBJECTS += $(ASM_OBJS)

# Create .o files from .bin files.
$(BUILD_DIR)/%.bin.o: %.bin
	@$(PRINT)$(GREEN)objcopying binary file: $(ENDGREEN)$(BLUE)$<$(ENDBLUE)$(ENDLINE)
	@mkdir -p $(shell dirname $@)
	$(V)$(LD) -r -b binary -o $@ $<

$(BUILD_DIR)/$(LD_SCRIPT): $(LD_SCRIPT)
	@mkdir -p $(BUILD_DIR)
	@$(PRINT)$(GREEN)Preprocessing linker script: $(ENDGREEN)$(BLUE)$<$(ENDBLUE)$(ENDLINE)
	$(V)$(CPP) -P -DBUILD_PATH=$(BUILD_DIR) $< -o $@
#Temporary hack for noload segment wrong alignment
	@sed -r -i 's/\.main_bss \(NOLOAD\) : SUBALIGN\(4\)/.main_bss main_SDATA_END (NOLOAD) : SUBALIGN(4)/g' $@

ifeq ($(SKIP_ASM),1)
# Prevent building ELF if SKIP_ASM != 1
$(BUILD_DIR)/$(TARGET).elf:
	@echo "Skipping linking (SKIP_ASM != 1)"
else
# Link the .o files into the .elf
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) $(BUILD_DIR)/$(LD_SCRIPT)
	@$(PRINT)$(GREEN)Linking elf file: $(ENDGREEN)$(BLUE)$@$(ENDBLUE)$(ENDLINE)
	$(V)$(LD) $(LDFLAGS) -o $@
endif

ifeq ($(SKIP_ASM),1)
$(EXE):
	@echo "Skipping EXE creation (SKIP_ASM=1)"
else
# Convert the .elf to the final exe
$(EXE): $(BUILD_DIR)/$(TARGET).elf
	@$(PRINT)$(GREEN)Creating EXE: $(ENDGREEN)$(BLUE)$@$(ENDBLUE)$(ENDLINE)
	$(V)$(OBJCOPY) $< $@ -O binary
	$(V)$(OBJCOPY) -O binary $< $@
ifeq ($(COMPARE),1)
	@$(DIFF) $(BASEEXE) $(EXE) && printf "OK\n" || (echo 'The build succeeded, but did not match the base EXE. This is expected if you are making changes to the game. To skip this check, use "make COMPARE=0".' && false)
endif
endif

### Make Settings ###

.PHONY: all clean distclean setup split

# Remove built-in implicit rules to improve performance
MAKEFLAGS += --no-builtin-rules

# Print target for debugging
print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true
