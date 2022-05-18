
#version 330 core
#define MAX_STEPS 10
#define MAX_DIST 10.
#define SURF_DIST 0.5

out vec4 FragColor;
in vec4 gl_FragCoord;
uniform vec2 iResolution;

vec2 GetDist(vec3 p) {
    float plane = p.y;
    vec4 s = vec4(0, 1, 6, 1.);
    float sphereDist = length(p-s.xyz)-s.w;
    
    float d = MAX_DIST;
    float mat = 0.;
    if(plane < d) {
         d = plane;
         mat = 1.;
    }
    if(sphereDist < d) {
        d = sphereDist;
        mat = 2.;
    }

    return vec2(d, mat);
}

vec2 RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    float mat = 0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        vec2 dd = GetDist(p);
        float dS = dd.x;
        mat = dd.y;
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST) break;
    }
    
    return vec2(dO, mat);
}

vec4 GetNormal(vec3 p) {
    vec2 dd = GetDist(p);
	float d = dd.x;
    vec2 e = vec2(.001, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy).x,
        GetDist(p-e.yxy).x,
        GetDist(p-e.yyx).x);
    
    return vec4(normalize(n), dd.y);
}


float GetLight(vec3 p) {
    vec3 lightPos = vec3(3, 5, 4);
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p).xyz;

    
    float dif = clamp(dot(n, l)*.5+.5, 0., 1.);
    //float d = RayMarch(p+n*SURF_DIST*2., l).x;
    //if(p.y<.01 && d<length(lightPos-p)) dif *= .5;    
    return dif;
}
vec3 getMat(float id, vec3 p) {
    vec3 col = vec3(1, 1, 1);
    vec3 dir = normalize(p);
    if (id <= 0.1) {
        float a = 1.;
        col = vec3(1.0/255.0, 148.0/255.0, 154.0/255.0) * (step(0.9, fract(p.x*a)) + step(0.9, fract(p.z*a)));
        
    } else if (id == 1.) { 
        col = vec3(0.0, 67.0/255.0, 105.0/255.0) * (step(0.9, fract(p.x)) + step(0.9, fract(p.z)));
    } else if (id == 2.) {
        col = vec3(219.0/255.0, 31.0/255.0, 72.0/255.0);
    } else {
        col = vec3(229.0 / 255.0, 221.0 / 255.0, 200.0 / 255.0);
    }
    return col;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - .5*iResolution.xy)/iResolution.y;
    vec3 col = vec3(0);
    vec3 ro = vec3(0, 1, 0);
    vec3 rd = normalize(vec3(uv.x, uv.y-0., 1));
    
    vec2 dd = RayMarch(ro, rd);
    float d = dd.x;
    float matID = dd.y;
    
    vec3 p = ro + rd * d;
    if (d > MAX_DIST) {
        col = getMat(0., p);
    } else {
        if (matID == 2.) {
            col = GetLight(p) * getMat(matID, p);
        }
        else {
            col = getMat(matID, p);
        }
    }
    if (col.x == 0 && col.y == 0 && col.z == 0) {
        col = vec3(229.0 / 255.0, 221.0 / 255.0, 200.0 / 255.0);
    }


    // col = pow(col, vec3(.4545));
    FragColor = vec4(col, 1.0);
}