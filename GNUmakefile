################################################################################
SIDES = right left
PARTS = case top cover

################################################################################
SRC = minidox-case.scad
DIR = stls

################################################################################
define ADD_FEATURES
$(if $(findstring cover,$(1)),-D feature_cover=true -D feature_magnets=true)
endef

################################################################################
# $1: Side.
# $2: Part.
# $3: Features.
define ADD_PARTS
-D print_side='"$(1)"' -D print_part='"$(2)"' $(call ADD_FEATURES,$(3)) \
$(if $(findstring cover,$(2)),-D feature_magnets=true)
endef

################################################################################
# $1: Side.
# $2: Part.
define STL
all: $(DIR)/$(2)/$(2)-$(1).stl
$(DIR)/$(2)/$(2)-$(1).stl: $(SRC)
	@ mkdir -p `dirname $$@`
	openscad -o $$@ $(call ADD_PARTS,$(1),$(2)) $(SRC)

ifeq ($(2),case)
all: $(DIR)/$(2)/$(2)-$(1)-with-cover.stl
$(DIR)/$(2)/$(2)-$(1)-with-cover.stl: $(SRC)
	@ mkdir -p `dirname $$@`
	openscad -o $$@ $(call ADD_PARTS,$(1),$(2),cover) $(SRC)
endif
endef

################################################################################
$(foreach p,$(PARTS),$(foreach s,$(SIDES),$(eval $(call STL,$(s),$(p)))))
