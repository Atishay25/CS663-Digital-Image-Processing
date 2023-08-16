# Image Alignment and Warping

## Basics

- Digital Image : $I = f(x,y)$ where $(x,y)$ are spatial integer coordinates in a typical rectangular domain $\Omega = [0,W-1] \times [0,H-1]$
- The values are discretized and sampled at discrete locations
- Pixel : an ordered pair $(x,y)$, which is generally square, sometimes rectangular
- Pixel dimensions relate to **spacial resolution** of the sensor in camera
- Actual visual signal is analog, but digital cameras capture discrete version of it, which means that they capture stimulus only at specific points $(x,y)$ 
- Intensity values of $f(x,y) \in [0,255]$ , that is, 8 bit integers

## Image Alignment

Consider images $I_1$ and $I_2$ of a scene acquired through different viewpoints. Some pixels may be in same digital correspondence (same coordinates in image domain, but are not necessarily the same physical point), and some may be in physical correspondence (same physical point, but not necessarily the same coordinates in image domain). Note that image domain = $\Omega$

### Alignment

- $I_1$ and $I_2$ are aligned if for every $(x,y)$ in $\Omega$, the pixels at $(x,y)$ in $I_1$ and $I_2$ are in physical correspondence, that is are same physical point.
- If not, then images are misaligned wrt each other, or we say there is relative motion between them
- Image Alignment (also called **Registration**) is process of correcting relative motion between $I_1$ and $I_2$

## Motion Models

- Denoting coordinates in $I_1$ as $(x_1, y_1)$ and in $I_2$ as $(x_2, y_2)$. There are several motion models -
1. Translation 

$$\forall (x_1, y_1) \in \Omega, \quad x_2 = x_1 + t_x \quad \text{and} \quad y_2 = y_1 + t_y$$

$$
\begin{pmatrix}
    x_2 \\
    y_2 \\
    1 \\
\end{pmatrix}=
\begin{pmatrix}
    1 & 0 & t_x \\
    0 & 1 & t_y \\
    0 & 0 & 1 \\
\end{pmatrix}
\cdot
\begin{pmatrix}
    x_1 \\
    y_1 \\
    1 \\
\end{pmatrix}
$$

2. Rotation about $(0,0)$ anti-clockwise through angle $\theta$

$$x_2 = x_1 \cos{\theta} - y_1 \sin{\theta}$$ $$y_2 = x_1 \sin{\theta} + y_1 \cos{\theta}$$

$$
\begin{pmatrix}
    x_2 \\
    y_2 \\
\end{pmatrix}=
\begin{pmatrix}
    \cos\theta & -\sin\theta \\
    \sin\theta & \cos\theta  \\
\end{pmatrix}
\cdot
\begin{pmatrix}
    x_1 \\
    y_1 \\
\end{pmatrix}
$$

3. Rotation about $(x_c,y_c)$ anti-clockwise through angle $\theta$
    $$x_2  = (x_1 - x_c) \cos{\theta} - (y_1 - y_c) \sin{\theta} + x_c$$ $$y_2 = (x_1 - x_c) \sin{\theta} + (y_1 - y_c) \cos{\theta} + y_c$$

    $$
    \begin{pmatrix}
        x_2 \\
        y_2 \\
        1 \\
    \end{pmatrix}=
    \begin{pmatrix}
        \cos\theta & -\sin\theta & x_c \\
        \sin\theta & \cos\theta & y_c \\
        0 & 0 & 1 \\
    \end{pmatrix}
    \cdot
    \begin{pmatrix}
        x_1 - x_c \\
        y_1 - y_c \\
        1 \\
    \end{pmatrix}
    $$

    The extra ones (3rd row) are called **homogeneous coordinates** - they  facilitate using matrix multiplication to represent translations

4. Rotation and Translation

    $$x_2  = (x_1 - x_c) \cos{\theta} - (y_1 - y_c) \sin{\theta} + t_x$$ $$y_2   = (x_1 - x_c) \sin{\theta} + (y_1 - y_c) \cos{\theta} + t_y$$

    $$
    \begin{pmatrix}
        x_2 \\
        y_2 \\
        1 \\
    \end{pmatrix}=
    \begin{pmatrix}
        \cos\theta & -\sin\theta & t_x \\
        \sin\theta & \cos\theta & t_y \\
        0 & 0 & 1 \\
    \end{pmatrix}
    \cdot
    \begin{pmatrix}
        x_1 - x_c \\
        y_1 - y_c \\
        1 \\
    \end{pmatrix}
    $$

5. Affine Transformation
    
    This means rotation, scalinf and shearing besides translation

    $$x_2  = (x_1 - x_c) \cos{\theta} - (y_1 - y_c) \sin{\theta} + x_c$$ $$y_2   = (x_1 - x_c) \sin{\theta} + (y_1 - y_c) \cos{\theta} + y_c$$

    $$
    \begin{pmatrix}
        x_2 \\
        y_2 \\
        1 \\
    \end{pmatrix}=
    \begin{pmatrix}
        A_{11} & A_{12} & t_x \\
        A_{21} & A_{22} & t_y \\
        0 & 0 & 1 \\
    \end{pmatrix}
    \cdot
    \begin{pmatrix}
        x_1  \\
        y_1  \\
        1 \\
    \end{pmatrix}
    $$

    Assumption - The $2 \times 2$ sub-matrix $A$ is NOT rank deficient,     otherwise it will transform 2-D figures into a line or a point

6. Scaling about the origin
    - Identity : $$x = v, y= w$$
        $$
        \begin{pmatrix}
        1  & 0 & 0\\
        0 & 1 & 0  \\
        0 & 0 & 1 \\
        \end{pmatrix}
        $$
    - Scaling : $$x = c_x v, y = c_y w$$
        $$
        \begin{pmatrix}
        c_x  & 0 & 0\\
        0 & c_y & 0  \\
        0 & 0 & 1 \\
        \end{pmatrix}
        $$

7. Shearing
    - Shear (vertical) : $$x = v + s_v w, y= w$$
        $$
        \begin{pmatrix}
        1  & 0 & 0\\
        s_v & 1 & 0  \\
        0 & 0 & 1 \\
        \end{pmatrix}
        $$
    - Scaling : $$x = v, y = s_h v + w$$
        $$
        \begin{pmatrix}
        1 & s_h & 0\\
        0 & 1 & 0  \\
        0 & 0 & 1 \\
        \end{pmatrix}
        $$

- The 2D affine motion model (including translation in X and Y direction) has 6 degrees of freedom, and it accounts for in-plane motion only, so it is not appropriate for 3D head profile view versus head frontal view
- Composition of multiple types of motion is given by multiplication of their corresponding matrices
- For example, first scaling (matrix $S$) then rotate (matrix $R$), then resultant transformation is = $RS$
- Motion compositions are not commutative ($RS \not ={SR}$)
- In actual coding, we do not use matrices for it, we implement the formula as is. Matrix-based motion representation is useful because it allows for a compact way to represent the composition of many different types of motion









