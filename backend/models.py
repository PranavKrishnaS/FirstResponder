from app import db

class Hospital(db.Model):
    hospitalName = db.Column(db.String(100), nullable=False, primary_key=True)
    hospitalContact = db.Column(db.String(15), nullable=False)
    hospitalCoordinates = db.Column(db.String(50), nullable=False)
    hospitalDescription = db.Column(db.String(200), nullable=True)
    
       

    def to_json(self):
        return {
            "hospitalName": self.hospitalName,
            "hospitalContact": self.hospitalContact,
            "hospitalCoordinates": self.hospitalCoordinates,
            "hospitalDescription": self.hospitalDescription
        }