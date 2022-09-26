#define REG_WIDTH 32
#define N_COUNTERS 24
#define N_CONF_REGS 1
#define OVERFLOW 1
#define QUOTA 1
#define MCCU 1
#define RDC 1
#define BASE_CFG 0
#define END_CFG 0
#define BASE_COUNTERS 1
#define END_COUNTERS 24
#define BASE_OVERFLOW_INTR 25
#define BASE_OVERFLOW_MASK 25
#define N_OVERFLOW_MASK_REGS 1
#define END_OVERFLOW_MASK 25
#define BASE_OVERFLOW_VECT 26
#define N_OVERFLOW_VECT_REGS 1
#define END_OVERFLOW_VECT 26
#define N_OVERFLOW_REGS 2
#define END_OVERFLOW_INTR 26
#define BASE_QUOTA_INTR 27
#define BASE_QUOTA_MASK 27
#define N_QUOTA_MASK_REGS 1
#define END_QUOTA_MASK 27
#define BASE_QUOTA_LIMIT 28
#define N_QUOTA_LIMIT_REGS 1
#define END_QUOTA_LIMIT 28
#define N_QUOTA_REGS 2
#define END_QUOTA_INTR 28
#define MCCU_WEIGHTS_WIDTH 8
#define MCCU_N_CORES 6
#define MCCU_N_EVENTS 2
#define BASE_MCCU_CFG 29
#define N_MCCU_CFG 1
#define END_MCCU_CFG 29
#define BASE_MCCU_LIMITS 30
#define N_MCCU_LIMITS 6
#define END_MCCU_LIMITS 35
#define BASE_MCCU_QUOTA 36
#define N_MCCU_QUOTA 6
#define END_MCCU_QUOTA 41
#define BASE_MCCU_WEIGHTS 42
#define N_MCCU_WEIGHTS 3
#define END_MCCU_WEIGHTS 44
#define N_MCCU_REGS 16
#define RDC_WEIGHTS_WIDTH 8
#define RDC_N_CORES 6
#define RDC_N_EVENTS 2
#define BASE_RDC_VECT 45
#define N_RDC_VECT_REGS 1
#define END_RDC_VECT 45
#define BASE_RDC_WEIGHTS 42
#define N_RDC_WEIGHTS 0
#define END_RDC_WEIGHTS 44
#define BASE_RDC_WATERMARK 46
#define N_RDC_WATERMARK 3
#define END_RDC_WATERMARK 48
#define N_RDC_REGS 4
#define CROSSBAR_INPUTS 256
#define BASE_CROSSBAR 49
#define N_CROSSBAR_CFG 6
#define END_CROSSBAR 54
#define N_CROSSBAR_REGS 6
#define TOTAL_NREGS 55
#define END_PMU (TOTAL_NREGS-1)

#define _PMU_REG_TYPE (volatile unsigned int * )
#define R2A (REG_WIDTH/8)
// PMU base address
#define _PMUREG (_PMU_REG_TYPE(PMU_ADDR))
// PMU counter base address
#define _PMU_COUNTERS (_PMU_REG_TYPE(PMU_ADDR + R2A * BASE_COUNTERS ))

// PMU crossbar base address
#define _PMU_CROSSBAR (_PMU_REG_TYPE(PMU_ADDR + R2A * BASE_CROSSBAR))

// PMU overflow interrupt register base address
#define _PMU_OVERFLOW (_PMU_REG_TYPE(PMU_ADDR + R2A * BASE_OVERFLOW_INTR))

#define PMUCFG0 (_PMUREG[0]) // PMU configuration register 0
#define CROSSBAR_REG0 (_PMU_CROSSBAR[0]) // Crossbar output register 0
#define CROSSBAR_REG1 (_PMU_CROSSBAR[1]) // Crossbar output register 1
#define CROSSBAR_REG2 (_PMU_CROSSBAR[2]) // Crossbar output register 2
#define CROSSBAR_REG3 (_PMU_CROSSBAR[3]) // Crossbar output register 3
#define CROSSBAR_REG4 (_PMU_CROSSBAR[4]) // Crossbar output register 4
#define CROSSBAR_REG5 (_PMU_CROSSBAR[5]) // Crossbar output register 5

// PMU overflow (I)nterrupt (E)nable register 
#define PMU_OVERLFOW_IE (_PMU_OVERFLOW[0])

// PMU overflow (I)nterrupt (V)ector register
#define PMU_OVERFLOW_IV (_PMU_OVERFLOW[1])

#define CROSSBAR_OUTPUT_0 (0)
#define CROSSBAR_OUTPUT_1 (1)
#define CROSSBAR_OUTPUT_2 (2)
#define CROSSBAR_OUTPUT_3 (3)
#define CROSSBAR_OUTPUT_4 (4)
#define CROSSBAR_OUTPUT_5 (5)
#define CROSSBAR_OUTPUT_6 (6)
#define CROSSBAR_OUTPUT_7 (7)
#define CROSSBAR_OUTPUT_8 (8)
#define CROSSBAR_OUTPUT_9 (9)
#define CROSSBAR_OUTPUT_10 (10U)
#define CROSSBAR_OUTPUT_11 (11u)
#define CROSSBAR_OUTPUT_12 (12u)
#define CROSSBAR_OUTPUT_13 (13u)
#define CROSSBAR_OUTPUT_14 (14u)
#define CROSSBAR_OUTPUT_15 (15u)
#define CROSSBAR_OUTPUT_16 (16u)
#define CROSSBAR_OUTPUT_17 (17u)
#define CROSSBAR_OUTPUT_18 (18u)
#define CROSSBAR_OUTPUT_19 (19u)
#define CROSSBAR_OUTPUT_20 (20u)
#define CROSSBAR_OUTPUT_21 (21u)
#define CROSSBAR_OUTPUT_22 (22u)
#define CROSSBAR_OUTPUT_23 (23u)
#define CROSSBAR_OUTPUT_24 (24u)

#define EVENT_0 (0u)
#define EVENT_1 (1u)
#define EVENT_2 (2u)
#define EVENT_3 (3u)
#define EVENT_4 (4u)
#define EVENT_5 (5u)
#define EVENT_6 (6u)
#define EVENT_7 (7u)
#define EVENT_8 (8u)
#define EVENT_9 (9u)
#define EVENT_10 (10u)
#define EVENT_11 (11u)
#define EVENT_12 (12u)
#define EVENT_13 (13u)
#define EVENT_14 (14u)
#define EVENT_15 (15u)
#define EVENT_16 (16u)
#define EVENT_17 (17u)
#define EVENT_18 (18u)
#define EVENT_19 (19u)
#define EVENT_20 (20u)
#define EVENT_21 (21u)
#define EVENT_22 (22u)
#define EVENT_23 (23u)
#define EVENT_24 (24u)
#define EVENT_25 (25u)
#define EVENT_26 (26u)
#define EVENT_27 (27u)
#define EVENT_28 (28u)
#define EVENT_29 (29u)
#define EVENT_30 (30u)
#define EVENT_31 (31u)
#define EVENT_32 (32u)
#define EVENT_33 (33u)
#define EVENT_34 (34u)
#define EVENT_35 (35u)
#define EVENT_36 (36u)
#define EVENT_37 (37u)
#define EVENT_38 (38u)
#define EVENT_39 (39u)
#define EVENT_40 (40u)
#define EVENT_41 (41u)
#define EVENT_42 (42u)
#define EVENT_43 (43u)
#define EVENT_44 (44u)
#define EVENT_45 (45u)
#define EVENT_46 (46u)
#define EVENT_47 (47u)
#define EVENT_48 (48u)
#define EVENT_49 (49u)
#define EVENT_50 (50u)
#define EVENT_51 (51u)
#define EVENT_52 (52u)
#define EVENT_53 (53u)
#define EVENT_54 (54u)
#define EVENT_55 (55u)
#define EVENT_56 (56u)
#define EVENT_57 (57u)
#define EVENT_58 (58u)
#define EVENT_59 (59u)
#define EVENT_60 (60u)
#define EVENT_61 (61u)
#define EVENT_62 (62u)
#define EVENT_63 (63u)
#define EVENT_64 (64u)
#define EVENT_65 (65u)
#define EVENT_66 (66u)
#define EVENT_67 (67u)
#define EVENT_68 (68u)
#define EVENT_69 (69u)
#define EVENT_70 (70u)
#define EVENT_71 (71u)
#define EVENT_72 (72u)
#define EVENT_73 (73u)
#define EVENT_74 (74u)
#define EVENT_75 (75u)
#define EVENT_76 (76u)
#define EVENT_77 (77u)
#define EVENT_78 (78u)
#define EVENT_79 (79u)
#define EVENT_80 (80u)
#define EVENT_81 (81u)
#define EVENT_82 (82u)
#define EVENT_83 (83u)
#define EVENT_84 (84u)
#define EVENT_85 (85u)
#define EVENT_86 (86u)
#define EVENT_87 (87u)
#define EVENT_88 (88u)
#define EVENT_89 (89u)
#define EVENT_90 (90u)
#define EVENT_91 (91u)
#define EVENT_92 (92u)
#define EVENT_93 (93u)
#define EVENT_94 (94u)
#define EVENT_95 (95u)
#define EVENT_96 (96u)
#define EVENT_97 (97u)
#define EVENT_98 (98u)
#define EVENT_99 (99u)
#define EVENT_100 (100u)
#define EVENT_101 (101u)
#define EVENT_102 (102u)
#define EVENT_103 (103u)
#define EVENT_104 (104u)
#define EVENT_105 (105u)
#define EVENT_106 (106u)
#define EVENT_107 (107u)
#define EVENT_108 (108u)
#define EVENT_109 (109u)
#define EVENT_110 (110u)
#define EVENT_111 (111u)
#define EVENT_112 (112u)
#define EVENT_113 (113u)
#define EVENT_114 (114u)
#define EVENT_115 (115u)
#define EVENT_116 (116u)
#define EVENT_117 (117u)
#define EVENT_118 (118u)
#define EVENT_119 (119u)
#define EVENT_120 (120u)
#define EVENT_121 (121u)
#define EVENT_122 (122u)
#define EVENT_123 (123u)
#define EVENT_124 (124u)
#define EVENT_125 (125u)
#define EVENT_126 (126u)
#define EVENT_127 (127u)
#define EVENT_128 (128u)
#define EVENT_129 (129u)
#define EVENT_130 (130u)
#define EVENT_131 (131u)
#define EVENT_132 (132u)
#define EVENT_133 (133u)
#define EVENT_134 (134u)
#define EVENT_135 (135u)
#define EVENT_136 (136u)
#define EVENT_137 (137u)
#define EVENT_138 (138u)
#define EVENT_139 (139u)
#define EVENT_140 (140u)
#define EVENT_141 (141u)
#define EVENT_142 (142u)
#define EVENT_143 (143u)
#define EVENT_144 (144u)
#define EVENT_145 (145u)
#define EVENT_146 (146u)
#define EVENT_147 (147u)
#define EVENT_148 (148u)
#define EVENT_149 (149u)
#define EVENT_150 (150u)
#define EVENT_151 (151u)
#define EVENT_152 (152u)
#define EVENT_153 (153u)
#define EVENT_154 (154u)
#define EVENT_155 (155u)
#define EVENT_156 (156u)
#define EVENT_157 (157u)
#define EVENT_158 (158u)
#define EVENT_159 (159u)
#define EVENT_160 (160u)
#define EVENT_161 (161u)
#define EVENT_162 (162u)
#define EVENT_163 (163u)
#define EVENT_164 (164u)
#define EVENT_165 (165u)
#define EVENT_166 (166u)
#define EVENT_167 (167u)
#define EVENT_168 (168u)
#define EVENT_169 (169u)
#define EVENT_170 (170u)
#define EVENT_171 (171u)
#define EVENT_172 (172u)
#define EVENT_173 (173u)
#define EVENT_174 (174u)
#define EVENT_175 (175u)
#define EVENT_176 (176u)
#define EVENT_177 (177u)
#define EVENT_178 (178u)
#define EVENT_179 (179u)
#define EVENT_180 (180u)
#define EVENT_181 (181u)
#define EVENT_182 (182u)
#define EVENT_183 (183u)
#define EVENT_184 (184u)
#define EVENT_185 (185u)
#define EVENT_186 (186u)
#define EVENT_187 (187u)
#define EVENT_188 (188u)
#define EVENT_189 (189u)
#define EVENT_190 (190u)
#define EVENT_191 (191u)
#define EVENT_192 (192u)
#define EVENT_193 (193u)
#define EVENT_194 (194u)
#define EVENT_195 (195u)
#define EVENT_196 (196u)
#define EVENT_197 (197u)
#define EVENT_198 (198u)
#define EVENT_199 (199u)
#define EVENT_200 (200u)
#define EVENT_201 (201u)
#define EVENT_202 (202u)
#define EVENT_203 (203u)
#define EVENT_204 (204u)
#define EVENT_205 (205u)
#define EVENT_206 (206u)
#define EVENT_207 (207u)
#define EVENT_208 (208u)
#define EVENT_209 (209u)
#define EVENT_210 (210u)
#define EVENT_211 (211u)
#define EVENT_212 (212u)
#define EVENT_213 (213u)
#define EVENT_214 (214u)
#define EVENT_215 (215u)
#define EVENT_216 (216u)
#define EVENT_217 (217u)
#define EVENT_218 (218u)
#define EVENT_219 (219u)
#define EVENT_220 (220u)
#define EVENT_221 (221u)
#define EVENT_222 (222u)
#define EVENT_223 (223u)
#define EVENT_224 (224u)
#define EVENT_225 (225u)
#define EVENT_226 (226u)
#define EVENT_227 (227u)
#define EVENT_228 (228u)
#define EVENT_229 (229u)
#define EVENT_230 (230u)
#define EVENT_231 (231u)
#define EVENT_232 (232u)
#define EVENT_233 (233u)
#define EVENT_234 (234u)
#define EVENT_235 (235u)
#define EVENT_236 (236u)
#define EVENT_237 (237u)
#define EVENT_238 (238u)
#define EVENT_239 (239u)
#define EVENT_240 (240u)
#define EVENT_241 (241u)
#define EVENT_242 (242u)
#define EVENT_243 (243u)
#define EVENT_244 (244u)
#define EVENT_245 (245u)
#define EVENT_246 (246u)
#define EVENT_247 (247u)
#define EVENT_248 (248u)
#define EVENT_249 (249u)
#define EVENT_250 (250u)
#define EVENT_251 (251u)
#define EVENT_252 (252u)
#define EVENT_253 (253u)
#define EVENT_254 (254u)
#define EVENT_255 (255u)

#define _PMU_MCCU_RDC (_PMU_REG_TYPE(PMU_ADDR + R2A * BASE_MCCU_CFG))
#define _PMU_MCCU_QUOTA (_PMU_REG_TYPE(PMU_ADDR +  R2A * BASE_MCCU_LIMITS))
#define _PMU_RDC_WATERMARKS (_PMU_REG_TYPE(PMU_ADDR + R2A * BASE_RDC_WATERMARK))

#define PMUCFG1 (_PMU_MCCU_RDC[0]) // PMU configuration register 1

#define PMU_QUOTA_SET0 (_PMU_MCCU_QUOTA[0]) // Quota set register 
#define PMU_QUOTA_SET1 (_PMU_MCCU_QUOTA[1]) // Quota set register 
#define PMU_QUOTA_SET2 (_PMU_MCCU_QUOTA[2]) // Quota set register 
#define PMU_QUOTA_SET3 (_PMU_MCCU_QUOTA[3]) // Quota set register 
#define PMU_QUOTA_SET4 (_PMU_MCCU_QUOTA[4]) // Quota set register 
#define PMU_QUOTA_SET5 (_PMU_MCCU_QUOTA[5]) // Quota set register 

#define PMU_QUOTA_REM0 (_PMU_MCCU_QUOTA[6]) // Quota current remaining for core 0
#define PMU_QUOTA_REM1 (_PMU_MCCU_QUOTA[7]) // Quota current remaining for core 1
#define PMU_QUOTA_REM2 (_PMU_MCCU_QUOTA[8]) // Quota current remaining for core 2
#define PMU_QUOTA_REM3 (_PMU_MCCU_QUOTA[9]) // Quota current remaining for core 3
#define PMU_QUOTA_REM4 (_PMU_MCCU_QUOTA[10]) // Quota current remaining for core 4
#define PMU_QUOTA_REM5 (_PMU_MCCU_QUOTA[11]) // Quota current remaining for core 5

#define EVENT_WEIGHT_REG0 (_PMU_MCCU_QUOTA[12]) // Event weight register 0 (input 0 to 3)
#define EVENT_WEIGHT_REG1 (_PMU_MCCU_QUOTA[13]) // Event weight register 1 (input 4 to 7)
#define EVENT_WEIGHT_REG2 (_PMU_MCCU_QUOTA[14]) // Event weight register 2 (input 8 to 12)


#define _PMU_RDC_IV (_PMU_REG_TYPE(PMU_ADDR + BASE_RDC_VECT * R2A))
#define PMU_RDC_IV (_PMU_RDC_IV[0])

#define PMU_RDC_WATERMARK_REG0 (_PMU_RDC_WATERMARKS[0])
#define PMU_RDC_WATERMARK_REG1 (_PMU_RDC_WATERMARKS[1])

#define EV_WEIGHT_INPUT0 (0u)
#define EV_WEIGHT_INPUT1 (1u)
#define EV_WEIGHT_INPUT2 (2u)
#define EV_WEIGHT_INPUT3 (3u)
#define EV_WEIGHT_INPUT4 (4u)
#define EV_WEIGHT_INPUT5 (5u)
#define EV_WEIGHT_INPUT6 (6u)
#define EV_WEIGHT_INPUT7 (7u)

#define PMU_OVERFLOW_INT_INDEX (6u)
