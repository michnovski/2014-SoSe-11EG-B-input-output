class Stick {
	
	Tree tree;
	PVector rotation;
	float len;
	float depthFactor;
	float diameter;
	int birth;
	ArrayList<Stick> children;
	
	
	Stick(Tree _tree, int _depth, PVector _rotation) {
		
		this.birth = millis();
		this.tree = _tree;
		this.rotation = _rotation;
		this.len = _depth * _tree.stickLength;
		this.depthFactor = _depth/float(_tree.depth);
		this.diameter = this.depthFactor*30;
		
		this.children = new ArrayList<Stick>(); 
	}
	
	void addChild( Stick stick ) {
		
		this.children.add( stick );
	}
	
	void update() {
		
		for(int i=0;i<this.children.size();i++) {
			this.children.get(i).update();
		}
	}
	
	void paint() {

		float drawLen = this.len;
		float growTime = (1-this.depthFactor)*4000;
		int age = millis() - this.birth;
		
		float swingZ = radians( sin((frameCount/32.0) % 360)*0.5 );

		if( age < growTime ) {
			drawLen *=  (millis() - this.birth) / growTime;
		}
		
		stroke(255,64);
		fill(0);
		
		pushMatrix();
		rotateX( radians(this.rotation.x) );
		rotateY( radians(this.rotation.y) );
		rotateZ( radians(this.rotation.z) + swingZ );
		translate(0, -drawLen/2, 0);
		box(this.diameter, drawLen, this.diameter);
		
		translate(0, -drawLen/2, 0);
		
		
		for(int i=0;i<this.children.size();i++) {
			this.children.get(i).paint();
		}
		
		popMatrix();
	}
}