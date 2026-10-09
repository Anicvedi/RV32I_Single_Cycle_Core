import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.path import Path
import numpy as np

def generate_academic_datapath(output_png_path):
    fig, ax = plt.subplots(figsize=(22, 12), dpi=300)
    ax.set_xlim(-1.8, 19.4)
    ax.set_ylim(-4.8, 6.4)
    ax.set_aspect('equal')
    ax.axis('off')

    # Color palette: Pure Academic Monochrome (Black & White with subtle gray accents)
    wire_color = '#000000'
    ctrl_color = '#222222'
    block_edge = '#000000'
    block_fill = '#FFFFFF'
    ctrl_fill = '#FAFAFA'
    font_family = 'sans-serif'
    
    # Typography styles
    title_font = {'fontsize': 16.5, 'fontweight': 'bold', 'family': font_family}
    subtitle_font = {'fontsize': 10, 'fontstyle': 'italic', 'family': font_family, 'color': '#333333'}
    block_title_font = {'fontsize': 9.5, 'fontweight': 'bold', 'family': font_family}
    block_sub_font = {'fontsize': 7.5, 'family': font_family, 'color': '#333333'}
    port_font = {'fontsize': 7.5, 'family': font_family}
    bus_label_font = {'fontsize': 7.5, 'family': font_family, 'fontweight': 'bold'}
    ctrl_label_font = {'fontsize': 7.5, 'family': font_family, 'fontstyle': 'italic'}

    # -------------------------------------------------------------------------
    # 0. TITLE
    # -------------------------------------------------------------------------
    ax.text(8.8, 5.9, "SINGLE-CYCLE 32-BIT RISC-V (RV32I) PROCESSOR DATAPATH", 
            ha='center', va='center', **title_font)
    ax.text(8.8, 5.5, "Complete Microarchitectural Datapath Schematic --- Pure Academic Monochrome Specification (Patterson & Hennessy Topology)", 
            ha='center', va='center', **subtitle_font)

    # -------------------------------------------------------------------------
    # 1. DRAWING PRIMITIVES
    # -------------------------------------------------------------------------
    def draw_box(x, y, w, h, title, subtitle=None, is_ctrl=False):
        # centered at (x, y)
        fc = ctrl_fill if is_ctrl else block_fill
        ec = block_edge
        box = patches.FancyBboxPatch((x - w/2, y - h/2), w, h,
                                     boxstyle="round,pad=0.03,rounding_size=0.08" if is_ctrl else "square,pad=0",
                                     linewidth=1.2, edgecolor=ec, facecolor=fc, zorder=3)
        ax.add_patch(box)
        # Position title at top of box to prevent collision with internal port labels
        if subtitle:
            ax.text(x, y + h/2 - 0.32, title, ha='center', va='center', zorder=4, **block_title_font)
            ax.text(x, y + h/2 - 0.65, subtitle, ha='center', va='center', zorder=4, **block_sub_font)
        else:
            ax.text(x, y + h/2 - 0.35, title, ha='center', va='center', zorder=4, **block_title_font)

    def draw_mux(x, y, h, name="MUX", num_inputs=2):
        # 2:1 or 4:1 multiplexer trapezoid
        w = 0.5
        pts = [
            [x - w/2, y + h/2],
            [x + w/2, y + h*0.3],
            [x + w/2, y - h*0.3],
            [x - w/2, y - h/2],
            [x - w/2, y + h/2]
        ]
        poly = patches.Polygon(pts, closed=True, linewidth=1.1, edgecolor=block_edge, facecolor=block_fill, zorder=3)
        ax.add_patch(poly)
        ax.text(x, y, name, ha='center', va='center', rotation=90, fontsize=7.5, fontweight='bold', zorder=4)
        
        # input labels
        if num_inputs == 2:
            ax.text(x - w*0.28, y + h*0.25, "0", ha='center', va='center', fontsize=7, zorder=4)
            ax.text(x - w*0.28, y - h*0.25, "1", ha='center', va='center', fontsize=7, zorder=4)
        elif num_inputs == 4:
            ax.text(x - w*0.28, y + h*0.35, "0", ha='center', va='center', fontsize=7, zorder=4)
            ax.text(x - w*0.28, y + h*0.12, "1", ha='center', va='center', fontsize=7, zorder=4)
            ax.text(x - w*0.28, y - h*0.12, "2", ha='center', va='center', fontsize=7, zorder=4)
            ax.text(x - w*0.28, y - h*0.35, "3", ha='center', va='center', fontsize=7, zorder=4)

    def draw_adder(x, y, r=0.42):
        circle = patches.Circle((x, y), r, linewidth=1.1, edgecolor=block_edge, facecolor=block_fill, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y, "+", ha='center', va='center', fontsize=14, fontweight='bold', zorder=4)

    def draw_alu(x, y, w=1.7, h=2.5):
        # Classic 6-sided notched ALU polygon
        pts = [
            [x - w/2, y + h/2],       # top-left
            [x + w/2, y + h*0.28],    # top-right
            [x + w/2, y - h*0.28],    # bottom-right
            [x - w/2, y - h/2],       # bottom-left
            [x - w/2, y - h*0.16],    # notch lower
            [x - w/2 + 0.35, y],      # notch inner
            [x - w/2, y + h*0.16],    # notch upper
            [x - w/2, y + h/2]
        ]
        poly = patches.Polygon(pts, closed=True, linewidth=1.2, edgecolor=block_edge, facecolor=block_fill, zorder=3)
        ax.add_patch(poly)
        ax.text(x + 0.05, y, "ALU", ha='center', va='center', fontsize=11, fontweight='bold', zorder=4)

    def draw_and_gate(x, y, w=0.8, h=0.7):
        angles = np.linspace(np.pi/2, -np.pi/2, 25)
        arc_x = x + (w/2) * np.cos(angles)
        arc_y = y + (h/2) * np.sin(angles)
        
        pts = [[x - w/2, y - h/2], [x - w/2, y + h/2], [x, y + h/2]]
        for ax_pt, ay_pt in zip(arc_x, arc_y):
            pts.append([ax_pt, ay_pt])
        pts.extend([[x, y - h/2], [x - w/2, y - h/2]])
        
        poly = patches.Polygon(pts, closed=True, linewidth=1.1, edgecolor=block_edge, facecolor=block_fill, zorder=3)
        ax.add_patch(poly)
        ax.text(x - 0.08, y, "AND", ha='center', va='center', fontsize=7, fontweight='bold', zorder=4)

    def wire(pts, arrow=True, dashed=False, label=None, label_pos=0.5, label_side='above', font=bus_label_font):
        xs, ys = zip(*pts)
        ls = '--' if dashed else '-'
        lw = 0.9 if dashed else 1.0
        c = ctrl_color if dashed else wire_color
        ax.plot(xs, ys, color=c, linestyle=ls, linewidth=lw, zorder=2)
        if arrow:
            p_prev = pts[-2]
            p_last = pts[-1]
            dx = p_last[0] - p_prev[0]
            dy = p_last[1] - p_prev[1]
            dist = (dx**2 + dy**2)**0.5
            if dist > 0:
                ax.annotate('', xy=p_last, xytext=(p_last[0] - 0.01*dx/dist, p_last[1] - 0.01*dy/dist),
                            arrowprops=dict(arrowstyle="-|>", color=c, lw=lw, mutation_scale=9),
                            zorder=2)
        if label:
            total_len = sum(((pts[i+1][0]-pts[i][0])**2 + (pts[i+1][1]-pts[i][1])**2)**0.5 for i in range(len(pts)-1))
            target_len = total_len * label_pos
            curr = 0
            lx, ly = pts[0]
            for i in range(len(pts)-1):
                seg_len = ((pts[i+1][0]-pts[i][0])**2 + (pts[i+1][1]-pts[i][1])**2)**0.5
                if curr + seg_len >= target_len:
                    frac = (target_len - curr) / seg_len if seg_len > 0 else 0
                    lx = pts[i][0] + frac*(pts[i+1][0] - pts[i][0])
                    ly = pts[i][1] + frac*(pts[i+1][1] - pts[i][1])
                    break
                curr += seg_len
            
            va = 'bottom' if label_side == 'above' else ('top' if label_side == 'below' else 'center')
            ha = 'center'
            dy = 0.07 if label_side == 'above' else (-0.07 if label_side == 'below' else 0)
            ax.text(lx, ly + dy, label, ha=ha, va=va, zorder=5,
                    bbox=dict(boxstyle='square,pad=0.12', facecolor='white', edgecolor='none'),
                    **font)

    def draw_clock(x, y, size=0.18):
        # Academic pure white unshaded clock triangle
        tri = patches.Polygon([[x - size, y], [x, y + size*1.2], [x + size, y]],
                              closed=True, linewidth=1.0, edgecolor=block_edge, facecolor='white', zorder=4)
        ax.add_patch(tri)

    def dot(x, y):
        ax.plot(x, y, 'o', color=wire_color, markersize=3.6, zorder=5)

    # -------------------------------------------------------------------------
    # 2. PLACE BLOCKS (CANONICAL ALIGNMENT & AMPLE SPACING)
    # -------------------------------------------------------------------------
    # Main Datapath Baseline at y = 0
    # Next-PC Mux (x = -0.7)
    draw_mux(-0.7, 0.0, h=1.8, name="MUX", num_inputs=2)
    
    # Program Counter (x = 1.1)
    draw_box(1.1, 0.0, w=1.2, h=2.5, title="PC", subtitle="32-bit Reg")
    draw_clock(1.1, -1.25)
    
    # Instruction Memory (x = 3.9)
    draw_box(3.9, 0.0, w=2.2, h=3.0, title="Instruction Memory", subtitle="512 x 32-bit (Dist. RAM)")
    ax.text(2.95, -0.4, "Read\nAddr", ha='left', va='center', **port_font)
    ax.text(4.85, -0.4, "Instruction\n[31:0]", ha='right', va='center', **port_font)
    
    # PC+4 Adder (x = 2.5, y = 2.6)
    draw_adder(2.5, 2.6, r=0.40)
    ax.text(2.5, 2.0, "Add (PC+4)", ha='center', va='center', **block_sub_font)
    
    # Register File (x = 7.9)
    draw_box(7.9, 0.0, w=2.4, h=3.6, title="Register File", subtitle="32 x 32-bit (x0 = 0)")
    draw_clock(7.9, -1.8)
    # Port labels cleanly inside Register File
    ax.text(6.85, 0.65, "Read reg 1", ha='left', va='center', **port_font)
    ax.text(6.85, 0.15, "Read reg 2", ha='left', va='center', **port_font)
    ax.text(6.85, -0.45, "Write reg", ha='left', va='center', **port_font)
    ax.text(6.85, -1.05, "Write data", ha='left', va='center', **port_font)
    ax.text(8.95, 0.65, "Read data 1", ha='right', va='center', **port_font)
    ax.text(8.95, -0.35, "Read data 2", ha='right', va='center', **port_font)
    ax.text(7.4, 1.62, "RegWrite", ha='center', va='center', **port_font)
    
    # Immediate Generator (x = 7.9, y = -2.9)
    draw_box(7.9, -2.9, w=2.4, h=1.4, title="Imm Gen", subtitle="Sign Extension\n(I, S, B, U, J)")
    
    # ALUSrc Mux (x = 10.9, y = -0.55)
    draw_mux(10.9, -0.55, h=1.6, name="MUX", num_inputs=2)
    
    # 32-bit ALU (x = 12.8, y = 0.0)
    draw_alu(12.8, 0.0, w=1.7, h=2.6)
    ax.text(13.5, 0.45, "Zero", ha='right', va='center', **port_font)
    ax.text(13.5, -0.15, "ALU\nresult", ha='right', va='center', **port_font)
    
    # Branch Target Adder (x = 11.6, y = 2.6)
    draw_adder(11.6, 2.6, r=0.40)
    ax.text(11.6, 2.0, "Add (PC+Imm)", ha='center', va='center', **block_sub_font)
    
    # Branch AND gate (x = 14.2, y = 2.6)
    draw_and_gate(14.2, 2.6, w=0.8, h=0.7)
    
    # Data Memory (x = 16.0, y = 0.0)
    draw_box(16.0, 0.0, w=2.4, h=3.2, title="Data Memory", subtitle="4-Banked Dist. RAM\n(Byte/Half/Word)")
    draw_clock(16.0, -1.6)
    ax.text(14.95, 0.0, "Address", ha='left', va='center', **port_font)
    ax.text(14.95, -0.95, "Write data", ha='left', va='center', **port_font)
    ax.text(17.05, 0.0, "Read data", ha='right', va='center', **port_font)
    ax.text(15.5, 1.45, "MemRead", ha='center', va='center', **port_font)
    ax.text(16.4, 1.45, "MemWrite", ha='center', va='center', **port_font)
    
    # Writeback Mux (4:1) (x = 18.3, y = 0.0)
    draw_mux(18.3, 0.0, h=2.5, name="WB MUX", num_inputs=4)
    
    # Main Control Unit (x = 7.9, y = 3.7)
    draw_box(7.9, 3.7, w=2.6, h=1.3, title="Control Unit", subtitle="Hardwired Combinational\n(Opcode [6:0])", is_ctrl=True)

    # -------------------------------------------------------------------------
    # 3. ROUTE BUSES & WIRES (DEDICATED ORTHOGONAL CHANNELS)
    # -------------------------------------------------------------------------

    # --- Fetch Stage ---
    # Next-PC Mux -> PC
    wire([(-0.45, 0.0), (0.5, 0.0)], label="Next PC", label_pos=0.5, label_side='above')
    
    # PC -> IMEM
    wire([(1.7, 0.0), (2.8, 0.0)], label="PC [31:0]", label_pos=0.45, label_side='above')
    dot(2.0, 0.0)
    
    # PC tap -> PC+4 Adder
    wire([(2.0, 0.0), (2.0, 2.6), (2.1, 2.6)])
    # Constant 4 into PC+4 Adder top
    wire([(2.5, 3.5), (2.5, 3.0)], label="4", label_pos=0.4, label_side='above')
    
    # PC+4 output
    wire([(2.9, 2.6), (3.3, 2.6)])
    dot(3.3, 2.6)
    # PC+4 -> Next-PC Mux input 0 (loops left along y = 3.5)
    wire([(3.3, 2.6), (3.3, 3.5), (-1.2, 3.5), (-1.2, 0.45), (-0.95, 0.45)],
         label="PC + 4 (Sequential)", label_pos=0.35, label_side='above')
    # PC+4 -> WB Mux input 2 (route right along y = 3.5, above IMEM/RegFile/DMEM)
    wire([(3.3, 3.5), (6.2, 3.5)])
    wire([(6.2, 3.5), (6.2, 4.4), (17.8, 4.4), (17.8, -0.3), (18.05, -0.3)],
         label="PC + 4 (Link Return)", label_pos=0.55, label_side='above')
    
    # PC tap -> Branch Target Adder
    wire([(2.0, 2.1), (10.9, 2.1), (10.9, 2.6), (11.18, 2.6)])
    dot(2.0, 2.1)

    # --- Decode Stage ---
    # IMEM Instruction bus
    wire([(5.0, 0.0), (5.7, 0.0)], label="Instr [31:0]", label_pos=0.5, label_side='above')
    dot(5.7, 0.0)
    
    # Instruction slices:
    # Opcode [6:0] -> Control Unit
    wire([(5.7, 0.0), (5.7, 3.7), (6.6, 3.7)], label="Opcode [6:0]", label_pos=0.75, label_side='above')
    
    # rs1 [19:15] -> Read reg 1
    wire([(5.7, 0.65), (6.7, 0.65)], label="rs1 [19:15]", label_pos=0.5, label_side='above')
    dot(5.7, 0.65)
    
    # rs2 [24:20] -> Read reg 2
    wire([(5.7, 0.15), (6.7, 0.15)], label="rs2 [24:20]", label_pos=0.5, label_side='above')
    dot(5.7, 0.15)
    
    # rd [11:7] -> Write reg
    wire([(5.7, -0.45), (6.7, -0.45)], label="rd [11:7]", label_pos=0.5, label_side='above')
    dot(5.7, -0.45)
    
    # Instr [31:7] -> Imm Gen
    wire([(5.7, 0.0), (5.7, -2.9), (6.7, -2.9)], label="Instr [31:7]", label_pos=0.75, label_side='above')

    # --- Execute Stage ---
    # Read data 1 -> ALU Input A (Straight line!)
    wire([(9.1, 0.65), (11.95, 0.65)], label="Read data 1", label_pos=0.45, label_side='above')
    
    # Read data 2 -> ALUSrc Mux input 0 & Data Memory Write data
    wire([(9.1, -0.35), (9.8, -0.35)])
    dot(9.8, -0.35)
    wire([(9.8, -0.35), (9.8, -0.15), (10.65, -0.15)], label="Read data 2", label_pos=0.55, label_side='above')
    # Read data 2 -> Data Memory Write data (drops to y = -2.0)
    wire([(9.8, -0.35), (9.8, -2.0), (14.4, -2.0), (14.4, -0.95), (14.8, -0.95)],
         label="Write data [31:0]", label_pos=0.45, label_side='above')
    
    # Imm Gen output
    wire([(9.1, -2.9), (10.1, -2.9)])
    dot(10.1, -2.9)
    # ImmExt -> ALUSrc Mux input 1
    wire([(10.1, -2.9), (10.1, -0.95), (10.65, -0.95)], label="ImmExt [31:0]", label_pos=0.65, label_side='above')
    # ImmExt -> Branch Target Adder
    wire([(10.1, -2.9), (10.1, 2.45), (11.18, 2.45), (11.18, 2.6)])
    # ImmExt -> WB Mux input 3 (LUI bypass along y = -3.6)
    wire([(10.1, -2.9), (10.1, -3.6), (17.5, -3.6), (17.5, -0.87), (18.05, -0.87)],
         label="ImmExt (LUI)", label_pos=0.55, label_side='above')
    
    # ALUSrc Mux -> ALU Input B
    wire([(11.15, -0.55), (11.95, -0.55)], label="Operand B", label_pos=0.5, label_side='above')

    # --- Branch Logic ---
    # Branch Target Adder output -> Next-PC Mux input 1 (runs along y = 4.8 above Control Unit!)
    wire([(12.02, 2.6), (12.4, 2.6), (12.4, 4.8), (-1.0, 4.8), (-1.0, -0.45), (-0.95, -0.45)],
         label="Branch Target Address [31:0]", label_pos=0.45, label_side='above')
    
    # Branch AND gate:
    # Zero flag from ALU
    wire([(13.65, 0.45), (13.8, 0.45), (13.8, 2.45)], label="Zero", label_pos=0.5, label_side='above')
    # AND gate output -> PCSel (runs along y = 5.2 above everything!)
    wire([(14.6, 2.6), (14.8, 2.6), (14.8, 5.2), (-0.7, 5.2), (-0.7, 0.9)],
         label="PCSel", label_pos=0.35, label_side='above', dashed=True)

    # --- Memory & Writeback ---
    # ALU Result -> Data Memory Address
    wire([(13.65, -0.15), (14.3, -0.15)])
    dot(14.3, -0.15)
    wire([(14.3, -0.15), (14.3, 0.0), (14.8, 0.0)], label="ALU Result (Addr)", label_pos=0.5, label_side='above')
    # ALU Result -> WB Mux input 0 (up to y = 1.8)
    wire([(14.3, -0.15), (14.3, 1.8), (17.4, 1.8), (17.4, 0.87), (18.05, 0.87)],
         label="ALU Result [31:0]", label_pos=0.45, label_side='above')
    
    # Data Memory Read data -> WB Mux input 1
    wire([(17.2, 0.0), (18.05, 0.0)], label="Read data [31:0]", label_pos=0.45, label_side='above')
    
    # WB Mux output -> RegFile Write data (Global return bus at bottom y = -4.2)
    wire([(18.55, 0.0), (18.9, 0.0), (18.9, -4.2), (6.3, -4.2), (6.3, -1.05), (6.7, -1.05)],
         label="Writeback Data Bus [31:0] (ALU Result / Data Memory / PC+4 Link / LUI)", 
         label_pos=0.45, label_side='above')

    # -------------------------------------------------------------------------
    # 4. CONTROL SIGNALS (CLEAN DASHED ROUTING)
    # -------------------------------------------------------------------------
    # RegWrite: Control Unit -> RegFile
    wire([(7.4, 3.05), (7.4, 1.8)], dashed=True, label="RegWrite", label_pos=0.5, label_side='above', font=ctrl_label_font)
    
    # ALUSrc: Control Unit -> ALUSrc Mux
    wire([(8.8, 3.05), (8.8, 2.9), (10.9, 2.9), (10.9, 0.25)], dashed=True,
         label="ALUSrc", label_pos=0.45, label_side='above', font=ctrl_label_font)
    
    # ALUOp: Control Unit -> ALU
    wire([(9.2, 3.3), (12.8, 3.3), (12.8, 1.3)], dashed=True,
         label="ALUOp [3:0]", label_pos=0.4, label_side='above', font=ctrl_label_font)
    
    # Branch: Control Unit -> AND gate
    wire([(9.2, 3.7), (13.8, 3.7), (13.8, 2.75)], dashed=True,
         label="Branch", label_pos=0.35, label_side='above', font=ctrl_label_font)
    
    # MemRead / MemWrite: Control Unit -> Data Memory
    wire([(9.2, 4.0), (15.5, 4.0), (15.5, 1.6)], dashed=True,
         label="MemRead", label_pos=0.5, label_side='above', font=ctrl_label_font)
    wire([(9.2, 4.0), (16.4, 4.0), (16.4, 1.6)], dashed=True,
         label="MemWrite", label_pos=0.8, label_side='above', font=ctrl_label_font)
    
    # WBSel: Control Unit -> WB Mux
    wire([(9.2, 4.2), (18.3, 4.2), (18.3, 1.25)], dashed=True,
         label="WBSel [1:0]", label_pos=0.65, label_side='above', font=ctrl_label_font)

    # -------------------------------------------------------------------------
    # 5. FOOTER SPECIFICATION
    # -------------------------------------------------------------------------
    ax.text(8.8, -4.6, 
            "Target FPGA: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Basys 3)  |  Memory: Pure Distributed RAM (512x32)  |  CPI = 1.0 (Single-Cycle RV32I)",
            ha='center', va='center', fontsize=8, color='#444444')

    plt.tight_layout()
    fig.savefig(output_png_path, bbox_inches='tight', facecolor='white', edgecolor='none')
    plt.close(fig)
    print("Academic Datapath generated successfully at:", output_png_path)

if __name__ == '__main__':
    generate_academic_datapath(r'C:\temp\RV32I_Single_Cycle_Core\docs\RV32I_Single_Cycle_Datapath_Academic.png')
